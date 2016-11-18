import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import './annotation.dart';
import './base.dart';
import './gcloud_context.dart';
import './logger.dart';
import './server.dart' as server;
import './task.dart';

enum TaskStatus { success, failure, internalError }

EnumCodec<TaskStatus> _taskStatusCodec = new EnumCodec<TaskStatus>();

/// [TaskRunResult] contains information about the result of task execution
/// submitted to [runBeaver].
class TaskRunResult {
  /// The [Config] instance used to run the task.
  final Config config;

  /// The task execution status.
  final TaskStatus status;

  /// The '\n' delimited task log.
  final String log;

  factory TaskRunResult.fromJson(json) {
    if (json is String) {
      json = JSON.decode(json);
    }
    if (json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    String configJson = json['config'];
    String statusString = json['status'];
    String log = json['log'];
    if (configJson == null || statusString == null || log == null) {
      throw new ArgumentError('The given json does not contain all the fields');
    }

    TaskStatus status = _taskStatusCodec.encode(statusString);
    Config config = new Config.fromJson(configJson);
    return new TaskRunResult._internal(config, status, log);
  }

  Map toJson() => {
        'config': config.toJson(),
        'status': _taskStatusCodec.decode(status),
        'log': log
      };

  TaskRunResult._internal(this.config, this.status, this.log);
}

Future<TaskRunResult> _runTask(
    Context context, /* Task|ExecuteFunc */ task) async {
  task = task is Task ? task : new Task.fromFunc(task as ExecuteFunc);
  var status = TaskStatus.success;
  final logger = context.logger;
  try {
    await task.execute(context);
  } on TaskException catch (e) {
    logger.shout(e);
    status = TaskStatus.failure;
  } catch (e) {
    logger.shout(e);
    status = TaskStatus.internalError;
  }
  return new TaskRunResult._internal(context.config, status, logger.toString());
}

void _dumpClassMap(String prefix, Map<String, ClassMirror> taskClassMap) {
  print(prefix);
  taskClassMap.forEach((name, cm) {
    print('  $name -> ${cm.qualifiedName}');
  });
}

Future<Map<String, ContextPart>> _createContextPartMap(Config config) async {
  Map<String, ClassMirror> contextPartClassMap =
      queryNameClassMapByAnnotation(ContextPartClass);
  _dumpClassMap('List of ContextPart classes:', contextPartClassMap);

  final partMap = {};
  contextPartClassMap.forEach((String name, ClassMirror contextParClass) {
    partMap[name] = newInstance('', contextParClass, []);
  });
  await Future
      .wait(partMap.values.map((ContextPart part) => part.setUp(config)));
  return partMap;
}

Future<GCloudContext> _createGCloudContext(Config config) async {
  final logger = new BeaverLogger();
  final partMap = await _createContextPartMap(config);
  final context = new GCloudContext(config, logger, partMap);
  await context.setUp();

  return context;
}

CommandWrapper _ssh = new CommandWrapper('ssh');

Future _prepareBeaverTaskServer(
    GCloudContext context, String remoteAddr) async {
  const sshKeyPath = '/tmp/id_rsa';
  final sshKeyFile = new File(sshKeyPath);
  if (!await sshKeyFile.exists()) {
    final siteId = context.config.buildInfo['site_id'];
    final bucket = context.storage.bucket('beaver-$siteId');
    await sshKeyFile.openWrite().addStream(bucket.read('id_rsa'));
    await chmod('0600', sshKeyFile);
  }

  String host = 'beaver@$remoteAddr';
  await _ssh.run([
    '-T',
    '-o',
    'StrictHostKeyChecking=no',
    '-o',
    'UserKnownHostsFile=/dev/null',
    '-i',
    sshKeyPath,
    host
  ], stdin: [
    'EOF',
    'sudo apt-get update',
    'sudo apt-get -y install apt-transport-https',
    "sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | tac | apt-key add -'",
    "sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'",
    'sudo apt-get update',
    'sudo apt-get -y --force-yes install dart',
    'sudo apt-get -y install git',
    'git clone https://github.com/fluidic/beaver',
    'cd beaver/beaver_task',
    '/usr/lib/dart/bin/pub get',
    "sh -c 'nohup dart bin/beaver_task_server.dart > foo.out 2> foo.err < /dev/null &'"
  ]);
}

Future<TaskRunResult> _requestRunBeaver(
    String remoteAddr, taskJson, Config config) async {
  Uri endpoint = Uri.parse('http://$remoteAddr:${server.port}/run');
  if (taskJson is String) {
    taskJson = JSON.decode(taskJson);
  }
  if (taskJson is! Map) {
    throw new ArgumentError('json must be a Map or a String encoding a Map.');
  }

  final body = {'task': taskJson, 'config': config.toJson()};
  http.Response response = await http.post(endpoint,
      headers: {'content-type': 'application/json'}, body: JSON.encode(body));
  if (response.statusCode != 200) {
    throw new Exception('Fail to run task: ${response.body}');
  }
  final resultJson = JSON.decode(response.body);
  return new TaskRunResult.fromJson(resultJson);
}

Future<String> _readSshPublicKey(GCloudContext context) {
  final siteId = context.config.buildInfo['site_id'];
  final bucket = context.storage.bucket('beaver-$siteId');
  final stream = bucket.read('id_rsa.pub');
  return stream.transform(const Utf8Decoder()).join('');
}

Future<TaskRunResult> runBeaver(json, Config config,
    {bool newVM: false}) async {
  if (json == null) {
    throw new ArgumentError('json is required.');
  }
  if (config == null) {
    throw new ArgumentError('config is required.');
  }

  // Turn on all logging levels.
  Logger.root.level = Level.ALL;

  GCloudContext context;
  switch (config.cloudType) {
    case 'gcloud':
      context = await _createGCloudContext(config);
      break;
    default:
      throw new ArgumentError('Unknown cloud_type ${config.cloudType}');
  }

  if (newVM) {
    final sshKey = await _readSshPublicKey(context);
    CreateVMResult vm = await context.createVM(sshPublicKey: sshKey);
    final remoteAddr = vm.networkIPs.first;
    await _prepareBeaverTaskServer(context, remoteAddr);

    // FIXME: Adjust the delay.
    // Wait a few seconds until the task server is up and running.
    await new Future.delayed(new Duration(seconds: 5));

    TaskRunResult result = await _requestRunBeaver(remoteAddr, json, config);
    await context.deleteVM(vm.name);
    return result;
  } else {
    Task task = new Task.fromJson(json);
    return _runTask(context, task);
  }
}
