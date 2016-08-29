import 'dart:async';
import 'dart:io';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';

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
  final projectStore = new ProjectStore(ConnectorType.mapInMemory);
  return new Context(logger, projectStore);
}

Future<Null> _trigger_handler(Context context, String projectId,
    String triggerType, Map<String, Object> data, HttpRequest request) async {
  final project = await context.projectStore.getProject(projectId);
  context.logger.info('Project found: ${project}');

  final eventDetector =
      getEventDetector(triggerType, context, request.headers, data);
  final event = eventDetector.event;
  context.logger.info('Event detected: ${event}');

  final taskInstanceRunner = new TaskInstanceRunner(context, event, project);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstance Running Result: ${result}');
}

// FIXME: data and request are dependent on triggerType. Make it optional.
Future<Null> trigger_handler(
    String projectId, String triggerType, Map<String, Object> data,
    {HttpRequest request}) async {
  final context = _createContext();

  try {
    await _trigger_handler(context, projectId, triggerType, data, request);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
