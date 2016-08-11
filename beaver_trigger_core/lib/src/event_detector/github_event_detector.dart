import 'dart:io';

import '../base.dart';

class GithubEventDetector implements EventDetector {
  final HttpHeaders _headers;
  final _jsonBody;

  GithubEventDetector(this._headers, this._jsonBody);

  @override
  String get event {
    final githubEvent = _headers.value('X-Github-Event');
    if (githubEvent == null) {
      return null;
    }

    final refType = _jsonBody['ref_type'];
    if (refType == null) {
      return null;
    }

    return 'github_event_' + githubEvent + '_' + refType;
  }
}