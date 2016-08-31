import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './event_detector.dart';
import './task_instance_runner.dart';

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
Map findTrigger(Context context, List<Map> triggers, String url, String event) {
  return triggers.firstWhere((trigger) {
    if (trigger['url'] == url && trigger['events'].contains(event)) {
      return true;
    }
  });
}

Future<Null> _triggerHandler(
    Context context,
    String projectId,
    String triggerType,
    Map<String, Object> data,
    Map<String, String> requestHeaders) async {
  final project = await context.projectStore.getProject(projectId);
  context.logger.info('Project found: ${project}');

  final eventDetector =
      getEventDetector(triggerType, context, requestHeaders, data);
  final event = eventDetector.event;
  final url = eventDetector.url;
  context.logger.info('Event detected: ${event}');

  final triggers =
      (project.config['triggers'] as YamlList).toList(growable: false);
  final trigger = findTrigger(context, triggers, url, event);
  context.logger.info('Trigger is triggerred. ${trigger}');

  final taskInstanceRunner = new TaskInstanceRunner(context, trigger['task']);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstance Running Result: ${result}');
}

// FIXME: data and request are dependent on triggerType. Make it optional.
Future<Null> triggerHandler(
    String projectId, String triggerType, Map<String, Object> data,
    {Map<String, String> requestHeaders}) async {
  final context = _createContext();

  try {
    await _triggerHandler(
        context, projectId, triggerType, data, requestHeaders);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
