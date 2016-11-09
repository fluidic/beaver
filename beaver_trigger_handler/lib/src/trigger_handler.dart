import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:sprintf/sprintf.dart';

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

Map<String, Object> _getTriggerConfig(Project project, String triggerName) {
  final triggers = project.config['triggers'] as List<Map<String, Object>>;
  return triggers.firstWhere((trigger) => trigger['name'] == triggerName,
      orElse: () => null);
}

// FIXME: Make this more simple.
bool _isMatchedTrigger(
    Map<String, Object> triggerConfig, ParsedTrigger parsedTrigger) {
  final url = triggerConfig['url'];
  if (url != null && url != parsedTrigger.url) {
    return false;
  }

  final events = triggerConfig['events'];
  if (events != null) {
    for (final event in triggerConfig['events']) {
      if (event == parsedTrigger.event) {
        return true;
      }
    }
    return false;
  } else {
    return true;
  }
}

void _setStatus(
    Context context, int statusCode, {List<dynamic> value}) {
  var message = status[statusCode];
  if (value != null) {
    message = sprintf(message, value);
  }
  context.status = statusCode.toString() + ': ' + message;
}

Future<Null> _triggerHandler(Context context, Trigger trigger, Project project,
    int buildNumber, CloudInfo cloudInfo) async {
  try {
    final triggerConfig = _getTriggerConfig(project, trigger.name);
    if (triggerConfig == null) {
      _setStatus(context, 400, value: [trigger.name]);
      throw new Exception(context.status);
    }
    context.logger.info('Trigger Configuration: $triggerConfig');

    final parsedTrigger = parseTrigger(context, trigger, triggerConfig['type']);
    context.logger.info('Trigger: $parsedTrigger');

    if (!_isMatchedTrigger(triggerConfig, parsedTrigger)) {
      _setStatus(context, 401);
      throw new Exception(context.status);
    }

    final tasks = (triggerConfig['task'] as YamlList).toList(growable: false)
        as List<Map<String, Object>>;
    final newVM = triggerConfig['newVM'] ?? false;
    final taskInstanceRunner = new TaskInstanceRunner(
        context, trigger, parsedTrigger, tasks, buildNumber, cloudInfo, newVM);
    final result = await taskInstanceRunner.run();
    context.logger.info('TaskRunResult: $result');

    await context.beaverStore.saveResult(
        project.name, buildNumber, '0: success', trigger,
        parsedTrigger: parsedTrigger,
        taskInstance: triggerConfig,
        taskRunResult: result);
    context.logger.info('Result is saved.');
  } catch (e) {
    if (context.status == null) {
      _setStatus(context, 999, value: [e.toString()]);
    }
    await context.beaverStore
        .saveResult(project.name, buildNumber, context.status, trigger);
    context.logger.shout(context.status);
  }
}

Future<int> triggerHandler(Uri requestUrl, Map<String, String> headers,
    Map<String, Object> payload) async {
  final context = await _createContext();

  try {
    context.logger.info('TriggerHandler is started.');

    final cloudInfo = new CloudInfo.fromUrl(requestUrl);
    final trigger = new Trigger(requestUrl, headers, payload);

    final project = await context.beaverStore.getProject(trigger.projectName);
    if (project == null) {
      _setStatus(context, 300, value: [trigger.projectName]);
      throw new Exception(context.status);
    }
    context.logger.info('Project: $project');

    final buildNumber =
        await context.beaverStore.getAndUpdateBuildNumber(trigger.projectName);
    context.logger.info('Build Number: $buildNumber');

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
