import '../base.dart';
import '../trigger_parser.dart';

// Referred from https://developer.github.com/v3/activity/events/types/.
final Map<String, Map<String, Object>> _eventMap = {
  'commit_comment': {
    'sub': {
      'key': 'action',
      'values': ['created']
    }
  },
  'create': {
    'sub': {
      'key': 'ref_type',
      'values': ['repository', 'branch', 'tag']
    }
  },
  'delete': {
    'sub': {
      'key': 'ref_type',
      'values': ['branch', 'tag']
    }
  },
  'deployment': {},
  'deployment_status': {},
  'follow': {},
  'fork': {},
  'gist': {
    'sub': {
      'key': 'action',
      'values': ['create', 'update']
    }
  },
  'gollum': {},
  'issue_comment': {
    'sub': {
      'key': 'action',
      'values': ['created', 'edited', 'deleted']
    }
  },
  'issue': {
    'sub': {
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
    }
  },
  'member': {
    'sub': {
      'key': 'action',
      'values': ['added']
    }
  },
  'membership': {
    'sub': {
      'key': 'action',
      'values': ['added', 'removed']
    }
  },
  'page_build': {},
  'public': {},
  'pull_request': {
    'sub': {
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
    }
  },
  'pull_request_review_comment': {
    'sub': {
      'key': 'action',
      'values': ['created', 'edited', 'deleted']
    }
  },
  'push': {},
  'release': {
    'sub': {
      'key': 'action',
      'values': ['published']
    }
  },
  'repository': {
    'sub': {
      'key': 'action',
      'values': ['created', 'deleted', 'publicized', 'privatized']
    }
  },
  'status': {},
  'team_add': {},
  'watch': {
    'sub': {
      'key': 'action',
      'values': ['started']
    }
  }
};

@TriggerParserClass('github')
class GitHubTriggerParser implements TriggerParser {
  @override
  Iterable<String> getMainEvents() {
    return _eventMap.keys;
  }

  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    context.logger.fine('GitHubTriggerParser started.');
    final event = _getEvent(trigger.headers, trigger.data);
    final url = _getUrl(trigger.data);
    return new ParsedTrigger(event, url, trigger.data);
  }

  Event _getEvent(Map<String, String> headers, Map<String, Object> data) {
    final mainEvent = headers['x-github-event'];
    if (mainEvent == null) {
      throw new Exception('This is not the GitHub event.');
    }

    final subEventMap = _eventMap[mainEvent]['sub'] as Map<String, Object>;
    if (subEventMap == null) {
      return new Event('github', mainEvent);
    }

    final subEvent = data[subEventMap['key']];
    // FIXME: Need to validate subEvent?
    return new Event('github', mainEvent, sub: subEvent);
  }

  String _getUrl(Map<String, Object> data) {
    return (data['repository'] as Map)['html_url'];
  }
}
