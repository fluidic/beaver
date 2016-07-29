import 'dart:async';
import 'dart:mirrors';

import './beaver_core_annotation.dart';
import './beaver_core_base.dart';
import './beaver_core_configuration.dart';
import './beaver_core_context.dart';
import './beaver_core_logger.dart';
import './beaver_core_reflection.dart';
import './beaver_core_reporter.dart';
import './beaver_core_task_runner.dart';

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

Future runBeaver(obj) async {
  final taskClassMap = _loadClassMapByAnnotation(reflectClass(TaskClass));
  final contextPartClassMap =
      _loadClassMapByAnnotation(reflectClass(ContextPartClass));
  _dumpClassMap('List of Task classes:', taskClassMap);
  _dumpClassMap('List of ContextPart classes:', contextPartClassMap);

  Configuration conf = new YamlConfiguration.fromFile('beaver.yaml');
  // FIXME: Don't hardcode parts and logger.
  final parts = [];
  final logger = new ConsoleLogger();
  Context context =
      await DefaultContext.create(conf, parts: parts, logger: logger);

  var task;
  if (obj is Function || obj is Task) {
    task = obj;
  } else if (obj is Iterable<Task>) {
    task = (Context context) => Future.forEach(obj, (t) => t.execute(context));
  } else {
    throw new ArgumentError(
        'argument must be either ExecuteFunc, Task or Iterable<Task>');
  }

  TaskRunner runner = new TaskRunner(context, task);
  TaskRunResult result = await runner.run();
  // FIXME: Don't hardcode reporter.
  JsonReporter reporter = new JsonReporter(result);
  print(reporter.toJson());
}
