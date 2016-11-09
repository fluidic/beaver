import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './cloud_info.dart';
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

Future<Null> _triggerHandler(Context context, Trigger trigger, Project project,
    int buildNumber, CloudInfo cloudInfo) async {
  try {
    final triggerConfig = _getTriggerConfig(project, trigger.name);
    if (triggerConfig == null) {
      throw new Exception('No Trigger Configuration for \'${trigger.name}\'');
    }
    context.logger.info('Trigger Configuration: $triggerConfig');

    final parsedTrigger = parseTrigger(context, trigger, triggerConfig['type']);
    context.logger.info('Trigger: $parsedTrigger');

    if (!_isMatchedTrigger(triggerConfig, parsedTrigger)) {
      // FIXME: Use more precise message.
      throw new Exception('Trigger and TriggerConfig are not matched.');
    }

    final tasks = (triggerConfig['task'] as YamlList).toList(growable: false)
        as List<Map<String, Object>>;
    final newVM = triggerConfig['newVM'] ?? false;
    final taskInstanceRunner = new TaskInstanceRunner(
        context, trigger, parsedTrigger, tasks, buildNumber, cloudInfo, newVM);
    final result = await taskInstanceRunner.run();
    context.logger.info('TaskRunResult: $result');

    await context.beaverStore.saveResult(project.name, buildNumber, trigger,
        parsedTrigger, triggerConfig, result);
    context.logger.info('Result is saved.');
  } catch (e) {
    context.logger.shout(e.toString());
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
      throw new Exception('No project for \'${trigger.projectName}\'.');
    }
    context.logger.info('Project: $project');

    final buildNumber =
        await context.beaverStore.getAndUpdateBuildNumber(trigger.projectName);
    context.logger.info('Build Number: $buildNumber');

    // Do the job in background
    _triggerHandler(context, trigger, project, buildNumber, cloudInfo);

    return buildNumber;
  } catch (e) {
    context.logger.shout(e.toString());
    throw e;
  }
}
