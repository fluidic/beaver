import './base.dart';
/// For [GithubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';
import './utils/reflection.dart';

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

  static const triggerDataPrefix = 'trigger:';

  bool isTriggerData(String str) {
    if (str.startsWith(triggerDataPrefix)) {
      return true;
    }
    return false;
  }

  String getTriggerData(String str) {
    if (!isTriggerData(str)) {
      throw new Exception('Not a trigger data.');
    }

    var keys = str.split(':')[1];
    keys = keys.split('.');

    var value = data;
    for (final key in keys) {
      value = value[key];
    }

    return value;
  }
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
