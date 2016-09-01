import './base.dart';

/// For [GithubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';
import './utils/reflection.dart';

abstract class TriggerParser {
  TriggerResult parse(
      Context context, Map<String, String> headers, Map<String, Object> data);
}

class TriggerResult {
  String event;
  String url;
  Map<String, Object> data;

  TriggerResult(this.event, this.url, this.data);
}

class TriggerParserClass {
  final String name;
  const TriggerParserClass(this.name);
}

TriggerResult parseTrigger(Context context, String triggerType,
    Map<String, String> headers, Map<String, Object> body) {
  final triggerParserClassMap = loadClassMapByAnnotation(TriggerParserClass);
  final triggerParserClass = triggerParserClassMap[triggerType];
  final triggerParser = newInstance(triggerParserClass, []);
  return triggerParser.parse(context, headers, body);
}
