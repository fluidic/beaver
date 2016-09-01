import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './task_instance_runner.dart';
import './trigger_parser.dart';

Logger _createLogger() {
  final logger = Logger.root;
  logger.level = Level.ALL;
  logger.clearListeners();
  logger.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  return logger;
}

Context _createContext() {
  final logger = _createLogger();
  // FIXME: Don't hardcode.
  final projectStore = new ProjectStore(ConnectorType.localMachine);
  return new Context(logger, projectStore);
}

// FIXME: Url is valid and unique even though trigger is not the repository?
// e.g. For GCloud Pub/Sub, can we use the url as a parameter here?
Map findTriggerConfig(
    Context context, List<Map> triggers, String url, String event) {
  return triggers.firstWhere((trigger) {
    if (trigger['url'] == url && trigger['events'].contains(event)) {
      return true;
    }
  });
}

Future<Null> _triggerHandler(
    Context context, Trigger trigger, String projectId) async {
  final project = await context.projectStore.getProject(projectId);
  context.logger.info('Project found: ${project}');

  final triggerResult = parseTrigger(context, trigger);
  context.logger.info('Event detected: ${triggerResult.event}');

  final triggers =
      (project.config['triggers'] as YamlList).toList(growable: false);
  final triggerConfig = findTriggerConfig(
      context, triggers, triggerResult.url, triggerResult.event);
  context.logger.info('Trigger is triggerred. ${triggerConfig}');

  final taskInstanceRunner =
      new TaskInstanceRunner(context, project, triggerConfig['task']);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstance Running Result: ${result}');
}

Future<Null> triggerHandler(Trigger trigger, String projectId) async {
  final context = _createContext();

  try {
    await _triggerHandler(context, trigger, projectId);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
