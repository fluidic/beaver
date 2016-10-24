import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './task_instance_runner.dart';
import './trigger_parser.dart';

BeaverStore _beaverStore;

void initTriggerHandler(BeaverStore beaverStore) {
  _beaverStore = beaverStore;
}

Logger _createLogger() {
  final logger = Logger.root;
  logger.level = Level.ALL;
  logger.clearListeners();
  logger.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  return logger;
}

Future<Context> _createContext() async {
  final logger = _createLogger();
  final beaverStore = _beaverStore;
  return new Context(logger, beaverStore);
}

List<Map<String, Object>> _getTriggerConfigs(Project project) {
  return (project.config['triggers'] as YamlList).toList(growable: false)
      as List<Map<String, Object>>;
}

Map<String, Object> _findTriggerConfig(
    List<Map<String, Object>> triggerConfigs, ParsedTrigger parsedTrigger) {
  return triggerConfigs.firstWhere((triggerConfig) {
    if (triggerConfig['url'] != parsedTrigger.url) {
      return false;
    }
    for (final eventStr in triggerConfig['events']) {
      final event = new Event.fromString(eventStr);
      return event.isMatch(parsedTrigger.event);
    }
  }, orElse: () => throw new Exception('No config for ${parsedTrigger}'));
}

Future<int> _triggerHandler(
    Context context, Trigger trigger, String projectName) async {
  context.logger.info('TriggerHandler is started.');
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    throw new Exception('No project for \'${projectName}\'.');
  }
  context.logger.info('Project: ${project}');
  final buildNumber =
      await context.beaverStore.getAndUpdateBuildNumber(projectName);

  final parsedTrigger = parseTrigger(context, trigger);
  context.logger.info('Trigger: ${parsedTrigger}');

  final triggerConfigs = _getTriggerConfigs(project);
  final matchedTriggerConfigs =
      _findTriggerConfig(triggerConfigs, parsedTrigger);
  context.logger
      .info('Matched Trigger Configuration: ${matchedTriggerConfigs}');

  final tasks = (matchedTriggerConfigs['task'] as YamlList)
      .toList(growable: false) as List<Map<String, Object>>;
  final taskInstanceRunner =
      new TaskInstanceRunner(context, project.config, parsedTrigger, tasks);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstanceRunResult: ${result}');

  await context.beaverStore.saveResult(projectName, buildNumber, trigger,
      parsedTrigger, matchedTriggerConfigs, result);
  context.logger.info('Result is saved.');
  return buildNumber;
}

Future<int> triggerHandler(Trigger trigger, String projectName) async {
  final context = await _createContext();

  try {
    return await _triggerHandler(context, trigger, projectName);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
