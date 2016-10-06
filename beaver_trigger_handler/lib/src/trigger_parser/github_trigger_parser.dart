import '../base.dart';
import '../trigger_parser.dart';

// Refered from https://developer.github.com/v3/activity/events/types/.
final Map<String, List<String>> _eventMap = {
  'commit_comment': {
    'key': 'action',
    'values': ['created']
  },
  'create': {
    'key': 'ref_type',
    'values': ['repository', 'branch', 'tag']
  },
  'delete': {
    'key': 'ref_type',
    'values': ['branch', 'tag']
  },
  'deployment': {},
  'deployment_status': {},
  'follow': {},
  'fork': {},
  'gist': {
    'key': 'action',
    'values': ['create', 'update']
  },
  'gollum': {},
  'issue_comment': {
    'key': 'action',
    'values': ['created', 'edited', 'deleted']
  },
  'issue': {
    'key': 'action',
    'values': [
      'assigned',
      'unassigned',
      'labeled',
      'unlabeled',
      'opened',
      'edited',
      'closed',
      'reopened'
    ]
  },
  'member': {
    'key': 'action',
    'values': ['added']
  },
  'membership': {
    'key': 'action',
    'values': ['added', 'removed']
  },
  'page_build': {},
  'public': {},
  'pull_request': {
    'key': 'action',
    'values': [
      'assigned',
      'unassigned',
      'labeled',
      'unlabeled',
      'opened',
      'edited',
      'closed',
      'reopened',
      'synchronize'
    ]
  },
  'pull_request_review_comment': {
    'key': 'action',
    'values': ['created', 'edited', 'deleted']
  },
  'push': {},
  'release': {
    'key': 'action',
    'values': ['published']
  },
  'repository': {
    'key': 'action',
    'values': ['created', 'deleted', 'publicized', 'privatized']
  },
  'status': {},
  'team_add': {},
  'watch': {
    'key': 'action',
    'values': ['started']
  }
};

@TriggerParserClass('github')
class GitHubTriggerParser implements TriggerParser {
  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    context.logger.fine('GitHubTriggerParser started.');
    final event = _getEvent(trigger.headers, trigger.data);
    final url = _getUrl(trigger.data);
    return new ParsedTrigger(event, url, trigger.data);
  }

  String _getEvent(Map<String, String> headers, Map<String, Object> data) {
    final mainEvent = headers['x-github-event'];
    if (mainEvent == null) {
      throw new Exception('This is not the GitHub event.');
    }

    final subEventMap = _eventMap[mainEvent];
    final subEvent = data[subEventMap['key']];
    if (subEvent == null || !subEventMap['values'].contains(subEvent)) {
      throw new Exception('Not supported GitHub event.');
    }

    return 'github_event_' + mainEvent + '_' + subEvent;
  }

  String _getUrl(Map<String, Object> data) {
    return (data['repository'] as Map)['html_url'];
  }
}
