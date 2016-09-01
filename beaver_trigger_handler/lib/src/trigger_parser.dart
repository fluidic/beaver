import './base.dart';

/// For [GithubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';
import './utils/reflection.dart';

abstract class TriggerParser {
  TriggerResult parse(Context context, Trigger trigger);
}

class TriggerResult {
  String event;
  // FIXME: Url is valid and unique even though trigger is not the repository?
  // e.g. For GCloud Pub/Sub, can we use the url as a parameter here?
  String url;
  Map<String, Object> data;

  TriggerResult(this.event, this.url, this.data);
}

class TriggerParserClass {
  final String name;
  const TriggerParserClass(this.name);
}

TriggerResult parseTrigger(Context context, Trigger trigger) {
  final triggerParserClassMap = loadClassMapByAnnotation(TriggerParserClass);
  final triggerParserClass = triggerParserClassMap[trigger.type];
  final triggerParser = newInstance(triggerParserClass, []);
  return triggerParser.parse(context, trigger);
}
