import 'package:beaver_utils/beaver_utils.dart';

import './base.dart';
/// For [GitHubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';

TriggerParser _getTriggerParser(String type) {
  final triggerParserClassMap =
      queryNameClassMapByAnnotation(TriggerParserClass);
  final triggerParserClass = triggerParserClassMap[type];
  return newInstance('', triggerParserClass, []);
}

ParsedTrigger parseTrigger(
    Context context, Trigger trigger, String triggerType) {
  final triggerParser = _getTriggerParser(triggerType);
  return triggerParser.parse(context, trigger);
}

Iterable<String> getMainEvents(String type) {
  final triggerParser = _getTriggerParser(type);
  return triggerParser.getMainEvents();
}
