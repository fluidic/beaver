import './base.dart';

/// For [GithubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';
import './utils/reflection.dart';

/// For [GithubTriggerParser].

abstract class TriggerParser {
  ParsedTrigger parse(Context context, Trigger trigger);
}

class ParsedTrigger {
  String event;
  // FIXME: Url is valid and unique even though trigger is not the repository?
  // e.g. For GCloud Pub/Sub, can we use the url as a parameter here?
  String url;
  Map<String, Object> data;

  ParsedTrigger(this.event, this.url, this.data);
}

class TriggerParserClass {
  final String name;
  const TriggerParserClass(this.name);
}

ParsedTrigger parseTrigger(Context context, Trigger trigger) {
  final triggerParserClassMap = loadClassMapByAnnotation(TriggerParserClass);
  final triggerParserClass = triggerParserClassMap[trigger.type];
  final triggerParser = newInstance(triggerParserClass, []);
  return triggerParser.parse(context, trigger);
}
