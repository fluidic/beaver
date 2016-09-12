import '../base.dart';
import '../trigger_parser.dart';

// FIXME: Add more events from https://developer.github.com/v3/activity/events/types/.
final Map<String, List<String>> _eventMap = {
  'create': {
    'key': 'ref_type',
    'values': ['branch', 'tag']
  },
  'pull_request': {
    'key': 'action',
    'values': ['opened', 'reopened', 'synchronized']
  }
};

@TriggerParserClass('github')
class GithubTriggerParser implements TriggerParser {
  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    context.logger.fine('GithubTriggerParser started.');
    final event = _getEvent(trigger.headers, trigger.data);
    final url = _getUrl(trigger.data);
    return new ParsedTrigger(event, url, trigger.data);
  }

  String _getEvent(Map<String, String> headers, Map<String, Object> data) {
    final mainEvent = headers['x-github-event'];
    if (mainEvent == null) {
      throw new Exception('This is not the Github event.');
    }

    final subEventMap = _eventMap[mainEvent];
    final subEvent = data[subEventMap['key']];
    if (subEvent == null || !subEventMap['values'].contains(subEvent)) {
      throw new Exception('Not supported Github event.');
    }

    return 'github_event_' + mainEvent + '_' + subEvent;
  }

  String _getUrl(Map<String, Object> data) {
    return (data['repository'] as Map)['html_url'];
  }
}
