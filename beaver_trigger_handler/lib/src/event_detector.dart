import './base.dart';

/// For [GithubEventDetector].
import './event_detector/github_event_detector.dart';
import './utils/reflection.dart';

// FIXME: Change the class name more proper.
abstract class EventDetector {
  String get event;
  String get url;
}

class EventDetectorClass {
  final String name;
  const EventDetectorClass(this.name);
}

EventDetector getEventDetector(String triggerType, Context context,
    Map<String, String> headers, Map jsonBody) {
  final eventDetectorClassMap = loadClassMapByAnnotation(EventDetectorClass);
  final eventDetectorClass = eventDetectorClassMap[triggerType];
  final args = [context, headers, jsonBody];
  final eventDetector = newInstance(eventDetectorClass, args);
  return eventDetector;
}
