import 'dart:async';
import 'dart:mirrors';

import './annotation.dart';
import './base.dart';
import './gcloud_context.dart';
import './gcloud.dart';
import './logger.dart';
import './utils/reflection.dart';

enum TaskStatus { Success, Failure }

class TaskRunResult {
  final Config config;

  final TaskStatus status;

  final String log;

  TaskRunResult._internal(this.config, this.status, this.log);
}

Future<TaskRunResult> _runTask(
    Context context, /* Task|ExecuteFunc */ task) async {
  task = task is Task ? task : new Task.fromFunc(task);
  var status = TaskStatus.Success;
  final logger = context.logger;
  try {
    await task.execute(context);
  } on TaskException catch (e) {
    logger.error(e);
    status = TaskStatus.Failure;
  } catch (e) {
    logger.error(e);
    status = TaskStatus.Failure;
  }
  return new TaskRunResult._internal(context.config, status, logger.toString());
}

String taskStatusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.Success:
      return 'success';
    case TaskStatus.Failure:
      return 'failure';
  }
}

Map<String, ClassMirror> _loadClassMapByAnnotation(ClassMirror annotation) {
  final taskClassMap = {};
  final cms = queryClassesByAnnotation(annotation);
  for (final cm in cms) {
    cm.metadata.forEach((md) {
      InstanceMirror metadata = md as InstanceMirror;
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

Future<Logger> _createLogger() async {
  // FIXME: Don't hardcode logger
  final logger = new ConsoleLogger();
  return new MemoryLogger(logger);
}

Future<Context> _createGCloudContext(Config config) async {
  final logger = await _createLogger();
  final partMap = await _createContextPartMap(config);
  final context = new GCloudContext(config, logger, partMap);
  await context.setUp();

  return context;
}

Future<TaskRunResult> runBeaver(
    String taskName, List<String> taskArgs, Config config,
    {bool newVM: false}) async {
  final taskClassMap = _loadClassMapByAnnotation(reflectClass(TaskClass));
  _dumpClassMap('List of Task classes:', taskClassMap);

  Context context;
  switch (config['cloud_type']) {
    case 'gcloud':
      context = await _createGCloudContext(config);
      break;
    default:
      throw new AssertionError(); // Unreachable
  }

  if (newVM) {
    CreateVMResult result = await createVM(context, config['zone']);
    // FIXME: Execute the task in the vm and return the result.
    await deleteVM(context, result.name, config['zone']);
    return null;
  } else {
    final task = newInstance('fromArgs', taskClassMap[taskName], [taskArgs]);
    return _runTask(context, task);
  }
}
