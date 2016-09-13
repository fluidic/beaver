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

Map _findTriggerConfig(List<Map> triggerConfigs, ParsedTrigger parsedTrigger) {
  return triggerConfigs.firstWhere((triggerConfig) {
    if (triggerConfig['url'] == parsedTrigger.url &&
        triggerConfig['events'].contains(parsedTrigger.event)) {
      return true;
    }
  });
}

Future<int> _triggerHandler(
    Context context, Trigger trigger, String projectId) async {
  final project =
      await context.configStore.getProjectAfterUpdatingBuildNumber(projectId);
  context.logger.info('Project found: ${project}');

  final parsedTrigger = parseTrigger(context, trigger);
  context.logger.info('Event detected: ${parsedTrigger.event}');

  final triggerConfig = _getTriggerConfigs(project);
  final taskInstance = _findTriggerConfig(triggerConfig, parsedTrigger);
  context.logger.info('Trigger is triggerred. ${triggerConfig}');

  final taskInstanceRunner = new TaskInstanceRunner(
      context, project.config, parsedTrigger, taskInstance);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstance Running Result: ${result}');

  final triggerResult =
      new TriggerResult(project, trigger, parsedTrigger, taskInstance, result);
  await context.configStore
      .saveResult(projectId, project.buildNumber, triggerResult);
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

class TriggerResult {
  final Project project;
  final Trigger trigger;
  final ParsedTrigger parsedTrigger;
  final Map<String, Object> taskInstance;
  final TaskInstanceRunResult taskInstanceRunResult;

  TriggerResult(this.project, this.trigger, this.parsedTrigger, this.taskInstance,
      this.taskInstanceRunResult);
}
