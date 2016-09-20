import './base.dart';
/// For [GithubTriggerParser].
import './trigger_parser/github_trigger_parser.dart';
import './utils/reflection.dart';

abstract class TriggerParser {
  ParsedTrigger parse(Context context, Trigger trigger);
}

class ParsedTrigger {
  final String event;
  // FIXME: Url is valid and unique even though trigger is not the repository?
  // e.g. For GCloud Pub/Sub, can we use the url as a parameter here?
  final String url;
  final Map<String, Object> data;

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

    var keys;
    try {
      keys = str.split(':')[1];
      keys = keys.split('.');
    } catch (_) {
      throw new Exception('Wrong format for a trigger data: ${str}');
    }

    try {
      var value = data;
      for (final key in keys) {
        value = value[key];
      }
      return value;
    } catch (_) {
      throw new Exception('No data for a trigger data: ${str}');
    }
  }

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer
      ..writeln('event: ${event}')
      ..writeln('url: ${url}')
      ..writeln('data: ${data}');
    return buffer.toString();
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
