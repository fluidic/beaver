import 'dart:async';
import 'dart:io';

import './base.dart';
import './event_detector/github_event_detector.dart';
import './job.dart';
import './trigger_config_store/trigger_config_memory_store.dart';
import './utils/enum_from_string.dart';

Future<Null> trigger(String triggerId, Map<String, Object> data,
    {HttpRequest request}) async {
  // FIXME: Don't hardcode.
  final context = new Context(new TriggerConfigMemoryStore());

  final triggerConfig = await context.triggerConfigStore.load(triggerId);

  // FIXME: Get EventDetector using the reflection.
  var event;
  switch (triggerConfig.sourceType) {
    case SourceType.github:
      final eventDetector =
          new GithubEventDetector(context, request.headers, data);
      event = eventDetector.event;
      break;
    default:
      throw new Exception('Not supported.');
  }

  final jobDescriptionLoader = new JobDescriptionLoader(context, triggerConfig);
  final jobDescription = await jobDescriptionLoader.load();

  final jobRunner = new JobRunner(context, event, jobDescription);
  final result = await jobRunner.run();

  // FIXME: Save result.
}

Future<String> setTrigger(Map<String, Object> data) async {
  // FIXME: Don't hardcode.
  final context = new Context(new TriggerConfigMemoryStore());

  return await setTriggerConfig(context,
      sourceTypeFromString(data['sourceType']), Uri.parse(data['sourceUrl']));
}
