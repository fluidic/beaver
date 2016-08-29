import 'dart:io';

import '../base.dart';
import '../event_detector.dart';

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

@EventDetectorClass('github')
class GithubEventDetector implements EventDetector {
  final Context _context;
  final HttpHeaders _headers;
  final _jsonBody;

  GithubEventDetector(this._context, this._headers, this._jsonBody);

  @override
  String get event {
    _context.logger.fine('GithubEventDetector started.');
    final mainEvent = _headers.value('X-Github-Event');
    if (mainEvent == null) {
      throw new Exception('This is not the Github event.');
    }

    final subEventMap = _eventMap[mainEvent];
    final subEvent = _jsonBody[subEventMap['key']];
    if (subEvent == null || !subEventMap['values'].contains(subEvent)) {
      throw new Exception('Not supported Github event.');
    }

    return 'github_event_' + mainEvent + '_' + subEvent;
  }

  @override
  String get url {
    return _jsonBody['repository']['html_url'];
  }
}
