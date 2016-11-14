import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './cloud_info.dart';
import './status.dart';
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

Future<Map<String, Object>> _getTriggerConfig(
    Context context, Project project, String triggerName) async {
  final triggerConfigs =
      project.config['triggers'] as List<Map<String, Object>>;
  final triggerConfig = triggerConfigs.firstWhere(
      (triggerConfig) => triggerConfig['name'] == triggerName, orElse: () {
    setStatus(context, 400, value: [triggerName]);
    throw new Exception(context.status);
  });
  context.logger.info('Trigger Configuration: $triggerConfig');
  context.triggerConfig = triggerConfig;
  return triggerConfig;
}

// FIXME: Make this more simple.
void _checkTriggerAndTriggerConfig(Context context,
    Map<String, Object> triggerConfig, ParsedTrigger parsedTrigger) {
  final url = triggerConfig['url'];
  if (url != null && url != parsedTrigger.url) {
    setStatus(context, 401);
    throw new Exception(context.status);
  }

  final events = triggerConfig['events'];
  if (events != null) {
    for (final event in triggerConfig['events']) {
      if (event == parsedTrigger.event) {
        return;
      }
    }
    setStatus(context, 402);
    throw new Exception(context.status);
  }
}

List<Map<String, Object>> _getTaskInstances(
    Context context, Map<String, Object> triggerConfig) {
  return (triggerConfig['task'] as YamlList).toList(growable: false)
      as List<Map<String, Object>>;
}

Future<TaskRunResult> _runTasks(
    Context context, List<Map<String, Object>> tasks, bool newVM) async {
  context.logger.finest('_runTasks is started.');
  final taskInstanceRunner = new TaskInstanceRunner(context, tasks, newVM);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskRunResult: $result');
  return result;
}

Future<Null> _saveSuccessResult(
    Context context, TaskRunResult taskRunResult) async {
  context.logger.finest('_saveSuccessResult is started.');
  await context.beaverStore.saveResult(
      context.project.name, context.buildNumber, '0: success', context.trigger,
      parsedTrigger: context.parsedTrigger,
      taskInstance: context.triggerConfig,
      taskRunResult: taskRunResult);
  context.logger.info('Result is saved.');
}

Future<Null> _saveFailureResult(Context context, String errorString) async {
  context.logger.finest('_saveFailureResult is started.');
  if (context.status == null) {
    setStatus(context, 999, value: [errorString]);
  }
  await context.beaverStore.saveResult(context.project.name,
      context.buildNumber, context.status, context.trigger,
      parsedTrigger: context.parsedTrigger,
      taskInstance: context.triggerConfig);
  context.logger.shout(context.status);
}

Future<Null> _triggerHandler(Context context, Trigger trigger, Project project,
    int buildNumber, CloudInfo cloudInfo) async {
  try {
    final triggerConfig =
        await _getTriggerConfig(context, project, trigger.name);
    final parsedTrigger = parseTrigger(context, trigger, triggerConfig['type']);
    _checkTriggerAndTriggerConfig(context, triggerConfig, parsedTrigger);

    final tasks = _getTaskInstances(context, triggerConfig);
    final newVM = triggerConfig['newVM'] ?? false;
    final result = await _runTasks(context, tasks, newVM);

    await _saveSuccessResult(context, result);
  } catch (e, stackTrace) {
    await _saveFailureResult(context, e.toString());
    context.logger.shout(e);
    context.logger.shout(stackTrace);
  }
}

Future<Project> _getProject(Context context, String projectName) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    setStatus(context, 300, value: [projectName]);
    throw new Exception(context.status);
  }
  context.logger.info('Project: $project');
  context.project = project;
  return project;
}

Future<int> _getBuildNumber(Context context, String projectName) async {
  final buildNumber =
      await context.beaverStore.getAndUpdateBuildNumber(projectName);
  context.logger.info('Build Number: $buildNumber');
  context.buildNumber = buildNumber;
  return buildNumber;
}

Future<int> triggerHandler(Uri requestUrl, Map<String, String> headers,
    Map<String, Object> payload) async {
  final context = await _createContext();

  try {
    context.logger.info('TriggerHandler is started.');

    final cloudInfo = new CloudInfo.fromUrl(requestUrl);
    context.cloudInfo = cloudInfo;
    final trigger = new Trigger(requestUrl, headers, payload);
    context.trigger = trigger;
    final project = await _getProject(context, trigger.projectName);
    final buildNumber = await _getBuildNumber(context, trigger.projectName);

    // Do the job in background
    _triggerHandler(context, trigger, project, buildNumber, cloudInfo);

    return buildNumber;
  } catch (e) {
    if (context.status == null) {
      setStatus(context, 999, value: [e.toString()]);
    }
    context.logger.shout(context.status);
    throw new Exception(context.status);
  }
}
