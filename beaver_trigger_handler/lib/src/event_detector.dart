import 'dart:io';

import './base.dart';
/// For [GithubEventDetector].
import './event_detector/github_event_detector.dart';
import './utils/enum.dart';
import './utils/reflection.dart';


abstract class EventDetector {
  String get event;
}

class EventDetectorClass {
  final String name;
  const EventDetectorClass(this.name);
}

EventDetector getEventDetector(
    SourceType sourceType, Context context, HttpHeaders headers, Map jsonBody) {
  final eventDetectorClassMap = loadClassMapByAnnotation(EventDetectorClass);
  final source = enumName(sourceType);
  final eventDetectorClass = eventDetectorClassMap[source];
  final args = [context, headers, jsonBody];
  final eventDetector = newInstance(eventDetectorClass, args);
  return eventDetector;
}
