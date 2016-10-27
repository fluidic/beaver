import '../base.dart';

@TriggerParserClass('github')
class GitHubTriggerParser implements TriggerParser {
  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    final event = _getEvent(trigger.headers, trigger.payload);
    final url = _getUrl(trigger.payload);
    return new ParsedTrigger(event, url, trigger.payload);
  }

  String _getEvent(Map<String, String> headers, Map<String, Object> data) {
    final event = headers['x-github-event'];
    if (event == null) {
      throw new Exception('This is not the GitHub event.');
    }

    return event;
  }

  String _getUrl(Map<String, Object> data) {
    return (data['repository'] as Map)['html_url'];
  }
}
