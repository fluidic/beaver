import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:logging/logging.dart';
import 'package:sprintf/sprintf.dart';
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
    _setStatus(context, 400, value: [triggerName]);
    throw new Exception(context.status);
  });
  context.logger.info('Trigger Configuration: $triggerConfig');
  return triggerConfig;
}

// FIXME: Make this more simple.
void _checkTriggerAndTriggerConfig(Context context,
    Map<String, Object> triggerConfig, ParsedTrigger parsedTrigger) {
  final url = triggerConfig['url'];
  if (url != null && url != parsedTrigger.url) {
    _setStatus(context, 401);
    throw new Exception(context.status);
  }

  final events = triggerConfig['events'];
  if (events != null) {
    for (final event in triggerConfig['events']) {
      if (event == parsedTrigger.event) {
        return;
      }
    }
    _setStatus(context, 402);
    throw new Exception(context.status);
  }
}

void _setStatus(Context context, int statusCode, {List<dynamic> value}) {
  var message = status[statusCode];
  if (value != null) {
    message = sprintf(message, value);
  }
  context.status = statusCode.toString() + ': ' + message;
}

List<Map<String, Object>> _getTaskInstances(
    Context context, Map<String, Object> triggerConfig) {
  return (triggerConfig['task'] as YamlList).toList(growable: false)
      as List<Map<String, Object>>;
}

Future<TaskRunResult> _runTasks(
    Context context,
    Trigger trigger,
    ParsedTrigger parsedTrigger,
    List<Map<String, Object>> tasks,
    int buildNumber,
    CloudInfo cloudInfo,
    bool newVM) async {
  final taskInstanceRunner = new TaskInstanceRunner(
      context, trigger, parsedTrigger, tasks, buildNumber, cloudInfo, newVM);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskRunResult: $result');
  return result;
}

Future<Null> _saveSuccessResult(
    Context context,
    Project project,
    int buildNumber,
    Trigger trigger,
    ParsedTrigger parsedTrigger,
    Map<String, Object> triggerConfig,
    TaskRunResult taskRunResult) async {
  await context.beaverStore.saveResult(
      project.name, buildNumber, '0: success', trigger,
      parsedTrigger: parsedTrigger,
      taskInstance: triggerConfig,
      taskRunResult: taskRunResult);
  context.logger.info('Result is saved.');
}

Future<Null> _saveFailureResult(Context context, Project project,
    int buildNumber, Trigger trigger, String errorString) async {
  if (context.status == null) {
    _setStatus(context, 999, value: [errorString]);
  }
  await context.beaverStore
      .saveResult(project.name, buildNumber, context.status, trigger);
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
    final result = await _runTasks(
        context, trigger, parsedTrigger, tasks, buildNumber, cloudInfo, newVM);

    await _saveSuccessResult(context, project, buildNumber, trigger,
        parsedTrigger, triggerConfig, result);
  } catch (e) {
    await _saveFailureResult(
        context, project, buildNumber, trigger, e.toString());
  }
}

Future<Project> _getProject(Context context, String projectName) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    _setStatus(context, 300, value: [projectName]);
    throw new Exception(context.status);
  }
  context.logger.info('Project: $project');
  return project;
}

Future<int> _getBuildNumber(Context context, String projectName) async {
  final buildNumber =
      await context.beaverStore.getAndUpdateBuildNumber(projectName);
  context.logger.info('Build Number: $buildNumber');
  return buildNumber;
}

Future<int> triggerHandler(Uri requestUrl, Map<String, String> headers,
    Map<String, Object> payload) async {
  final context = await _createContext();

  try {
    context.logger.info('TriggerHandler is started.');

    final cloudInfo = new CloudInfo.fromUrl(requestUrl);
    final trigger = new Trigger(requestUrl, headers, payload);
    final project = await _getProject(context, trigger.projectName);
    final buildNumber = await _getBuildNumber(context, trigger.projectName);

    // Do the job in background
    _triggerHandler(context, trigger, project, buildNumber, cloudInfo);

    return buildNumber;
  } catch (e) {
    if (context.status == null) {
      _setStatus(context, 999, value: [e.toString()]);
    }
    context.logger.shout(context.status);
    throw new Exception(context.status);
  }
}
