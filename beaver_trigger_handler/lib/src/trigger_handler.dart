import 'dart:async';

import 'package:beaver_config_store/beaver_config_store.dart';
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
  final configStore = new ConfigStore(StorageServiceType.localMachine);
  return new Context(logger, configStore);
}

List _getTriggerConfigs(Project project) {
  return (project.config['triggers'] as YamlList).toList(growable: false);
}

Map _findTriggerConfig(List<Map> triggerConfigs, TriggerResult triggerResult) {
  return triggerConfigs.firstWhere((triggerConfig) {
    if (triggerConfig['url'] == triggerResult.url &&
        triggerConfig['events'].contains(triggerResult.event)) {
      return true;
    }
  });
}

Future<int> _triggerHandler(
    Context context, Trigger trigger, String projectId) async {
  final project =
      await context.configStore.getProjectAfterUpdatingBuildNumber(projectId);
  context.logger.info('Project found: ${project}');

  final triggerResult = parseTrigger(context, trigger);
  context.logger.info('Event detected: ${triggerResult.event}');

  final triggerConfigs = _getTriggerConfigs(project);
  final triggerConfig = _findTriggerConfig(triggerConfigs, triggerResult);
  context.logger.info('Trigger is triggerred. ${triggerConfig}');

  final taskInstanceRunner =
      new TaskInstanceRunner(context, project, trigger, triggerConfig['task']);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstance Running Result: ${result}');

  await context.configStore.saveResult(projectId, project.buildNumber, result);
  context.logger.info(
      'TaskInstanceResult is saved: Build number: ${project.buildNumber}');
  return project.buildNumber;
}

Future<int> triggerHandler(Trigger trigger, String projectId) async {
  final context = _createContext();

  try {
    return await _triggerHandler(context, trigger, projectId);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
