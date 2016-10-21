import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:logging/logging.dart';

import './annotation.dart';
import './base.dart';
import './gcloud_context.dart';
import './logger.dart';

enum TaskStatus { Success, Failure, InternalError }

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

    Config configJson = json['config'];
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
  var status = TaskStatus.Success;
  final logger = context.logger;
  try {
    await task.execute(context);
  } on TaskException catch (e) {
    logger.shout(e);
    status = TaskStatus.Failure;
  } catch (e) {
    logger.shout(e);
    status = TaskStatus.InternalError;
  }
  return new TaskRunResult._internal(context.config, status, logger.toString());
}

Map<String, ClassMirror> _loadClassMapByAnnotation(ClassMirror annotation) {
  Map<String, ClassMirror> taskClassMap = {};
  final cms = queryClassesByAnnotation(annotation);
  for (final cm in cms) {
    cm.metadata.forEach((md) {
      InstanceMirror metadata = md;
      String name = metadata.getField(#name).reflectee;
      taskClassMap[name] = cm;
    });
  }
  return taskClassMap;
}

void _dumpClassMap(String prefix, Map<String, ClassMirror> taskClassMap) {
  print(prefix);
  taskClassMap.forEach((name, cm) {
    print('  ${name} -> ${cm.qualifiedName}');
  });
}

Future<Map<String, ContextPart>> _createContextPartMap(Config config) async {
  final contextPartClassMap =
      _loadClassMapByAnnotation(reflectClass(ContextPartClass));
  _dumpClassMap('List of ContextPart classes:', contextPartClassMap);

  final partMap = {};
  contextPartClassMap.forEach((String name, ClassMirror contextParClass) {
    partMap[name] = newInstance('', contextParClass, []);
  });
  await Future
      .wait(partMap.values.map((ContextPart part) => part.setUp(config)));
  return partMap;
}

Future<Context> _createGCloudContext(Config config) async {
  final logger = new BeaverLogger();
  final partMap = await _createContextPartMap(config);
  final context = new GCloudContext(config, logger, partMap);
  await context.setUp();

  return context;
}

Future<TaskRunResult> runBeaver(
    String taskName, List<String> taskArgs, Config config,
    {bool newVM: false}) async {
  // Turn on all logging levels.
  Logger.root.level = Level.ALL;

  final taskClassMap = _loadClassMapByAnnotation(reflectClass(TaskClass));
  _dumpClassMap('List of Task classes:', taskClassMap);

  GCloudContext context;
  switch (config.cloudType) {
    case 'gcloud':
      context = await _createGCloudContext(config);
      break;
    default:
      throw new ArgumentError('Unknown cloud_type ${config.cloudType}');
  }

  if (newVM) {
    CreateVMResult result = await context.createVM();
    // FIXME: Execute the task in the vm and return the result.
    await context.deleteVM(result.name);
    return null;
  } else {
    final task = newInstance('fromArgs', taskClassMap[taskName], [taskArgs]);
    return _runTask(context, task);
  }
}
