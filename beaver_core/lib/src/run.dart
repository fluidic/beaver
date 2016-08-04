import 'dart:async';
import 'dart:mirrors';

import './annotation.dart';
import './base.dart';
import './config.dart';
import './context.dart';
import './logger.dart';
import './reporter/json_reporter.dart';
import './task_runner.dart';
import './utils/reflection.dart';

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
    partMap[name] = contextParClass.newInstance(new Symbol(''), []).reflectee;
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

Future<Context> _createContext() async {
  Config config = new YamlConfig.fromFile('beaver.yaml');
  final logger = await _createLogger();
  final partMap = await _createContextPartMap(config);

  return new DefaultContext(config, logger, partMap);
}

Future runBeaver(String taskName) async {
  final taskClassMap = _loadClassMapByAnnotation(reflectClass(TaskClass));
  _dumpClassMap('List of Task classes:', taskClassMap);

  final context = await _createContext();
  final task = taskClassMap[taskName].newInstance(new Symbol(''), []);

  TaskRunner runner = new TaskRunner(context, task);
  TaskRunResult result = await runner.run();
  // FIXME: Don't hardcode reporter.
  JsonReporter reporter = new JsonReporter(result);
  print(reporter.toJson());
}
