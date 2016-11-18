import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import './base.dart';
import './exception.dart';
import './gcloud_context.dart';
import './server.dart' as server;
import './task.dart';

enum TaskStatus { success, failure, internalError }

EnumCodec<TaskStatus> _taskStatusCodec = new EnumCodec<TaskStatus>();

abstract class _TaskRunner {
  Future setUp(Context context);

  Future<TaskRunResult> run(Context context) => setUp(context)
      .then((_) => _runImpl(context).whenComplete(() => tearDown(context)));

  Future<TaskRunResult> _runImpl(Context context);

  Future tearDown(Context context);
}

class _LocalTaskRunner extends _TaskRunner {
  final Task _task;

  _LocalTaskRunner(json) : _task = new Task.fromJson(json);

  @override
  Future setUp(Context context) async {}

  @override
  Future<TaskRunResult> _runImpl(Context context) async {
    var status = TaskStatus.success;
    final logger = context.logger;
    try {
      await _task.execute(context);
    } on TaskException catch (e) {
      logger.shout(e);
      status = TaskStatus.failure;
    } catch (e) {
      logger.shout(e);
      status = TaskStatus.internalError;
    }
    return new TaskRunResult._internal(
        context.config, status, logger.toString());
  }

  @override
  Future tearDown(Context context) async {}
}

class _RemoteTaskRunner extends _TaskRunner {
  static CommandWrapper _ssh = new CommandWrapper('ssh');

  String _instanceName;

  String _host;

  dynamic _json;

  final Config _config;

  _RemoteTaskRunner(this._json, this._config);

  @override
  Future setUp(Context context) async {
    GCloudContext gcloud = context as GCloudContext;
    if (gcloud == null) {
      throw new ArgumentError(
          'GCloudContext is required to run task on the remote machine');
    }
    String sshKey = await _readSshPublicKey(gcloud);
    CreateVMResult vm = await gcloud.createVM(sshPublicKey: sshKey);
    _instanceName = vm.name;
    _host = vm.networkIPs.first;
    await _prepareTaskServer(gcloud);

    // FIXME: Adjust the delay.
    // Wait a few seconds until the task server is up and running.
    return new Future.delayed(new Duration(seconds: 5));
  }

  @override
  Future<TaskRunResult> _runImpl(Context context) async {
    if (_json is String) {
      _json = JSON.decode(_json);
    }
    if (_json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    Uri endpoint = Uri.parse('http://$_host:${server.port}/run');
    final body = {'task': _json, 'config': _config.toJson()};
    http.Response response = await http.post(endpoint,
        headers: {'content-type': 'application/json'}, body: JSON.encode(body));
    if (response.statusCode != 200) {
      throw new Exception('Fail to run task: ${response.body}');
    }
    final resultJson = JSON.decode(response.body);
    return new TaskRunResult.fromJson(resultJson);
  }

  @override
  Future tearDown(Context context) {
    GCloudContext gcloud = context as GCloudContext;
    if (gcloud == null) {
      throw new ArgumentError(
          'GCloudContext is required to run task on the remote machine');
    }
    return gcloud.deleteVM(_instanceName);
  }

  Future<String> _readSshPublicKey(GCloudContext context) {
    final siteId = context.config.buildInfo['site_id'];
    final bucket = context.storage.bucket('beaver-$siteId');
    final stream = bucket.read('id_rsa.pub');
    return stream.transform(const Utf8Decoder()).join('');
  }

  Future _prepareTaskServer(GCloudContext context) async {
    const sshKeyPath = '/tmp/id_rsa';
    final sshKeyFile = new File(sshKeyPath);
    if (!await sshKeyFile.exists()) {
      final siteId = context.config.buildInfo['site_id'];
      final bucket = context.storage.bucket('beaver-$siteId');
      await sshKeyFile.openWrite().addStream(bucket.read('id_rsa'));
      await chmod('0600', sshKeyFile);
    }

    String host = 'beaver@$_host';
    // Retry a few times as connecting to the ssh server can fail due to
    // timing issues.
    return retry(
        3,
        new Duration(seconds: 1),
        () => _ssh.run([
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
            ]));
  }
}

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
      context = await GCloudContext.create(config);
      break;
    default:
      throw new ArgumentError('Unknown cloud_type ${config.cloudType}');
  }

  final runner =
      newVM ? new _RemoteTaskRunner(json, config) : new _LocalTaskRunner(json);
  return runner.run(context);
}
