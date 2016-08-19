import 'dart:async';
import 'dart:io';

import './base.dart';
import './event_detector/github_event_detector.dart';
import './job.dart';
import './utils/enum_from_string.dart';

abstract class Trigger {
  final Map<String, Object> data;
  final Context context;

  Trigger(this.context, this.data);

  Future<Object> trigger();
}

class JobTrigger extends Trigger {
  // FIXME: request is valid only when triggered by http. A better way?
  final HttpRequest request;

  JobTrigger(Context context, Map<String, Object> data, {this.request})
      : super(context, data);

  @override
  Future<Map<String, Object>> trigger() async {
    final triggerConfigId = request.uri.pathSegments.last;
    final triggerConfig =
        await context.triggerConfigStore.load(triggerConfigId);

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

    final jobDescriptionLoader =
        new JobDescriptionLoader(context, triggerConfig);
    final jobDescription = await jobDescriptionLoader.load();

    final jobRunner = new JobRunner(context, event, jobDescription);
    final result = await jobRunner.run();

    return {'result': '{${result}}'};
  }
}

class SpecialTrigger extends Trigger {
  SpecialTrigger(Context context, Map<String, Object> data)
      : super(context, data);

  @override
  Future<Map<String, Object>> trigger() async {
    final id = await setTriggerConfig(
        context,
        sourceTypeFromString(data['sourceType']),
        Uri.parse(data['sourceUrl']),
        triggerTypeFromString(data['triggerType']));
    return {'id': '${id}'};
  }
}

bool isSpecialTriggerRequest(Uri url) {
  return url.pathSegments.last == 'special';
}
