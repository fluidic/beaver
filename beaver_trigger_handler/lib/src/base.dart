import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';

import './trigger_parser.dart';

class Context {
  final Logger logger;
  final BeaverStore beaverStore;

  Context(this.logger, this.beaverStore);
}

class Trigger {
  final String type;
  final Map<String, String> headers;
  final Map<String, Object> data;

  Trigger(this.type, this.headers, this.data);
}

class Event {
  final String type;
  final String main;
  final String sub;

  Event(this.type, this.main, {this.sub});

  factory Event.fromString(String event) {
    final list = event.split('_event_');
    final type = list[0];
    final rest = list[1];

    var main;
    final mainEvents = getMainEvents(type);
    for (final mainEvent in mainEvents) {
      if (rest.contains(mainEvent)) {
        main = mainEvent;
        break;
      }
    }

    var sub;
    if (rest == main) {
      sub = null;
    } else {
      sub = rest.split(main + '_')[1];
    }

    return new Event(type, main, sub: sub);
  }

  bool isMatch(Event event) {
    if (_isExactMatch(event) || _isSupersetOf(event)) {
      return true;
    }
    return false;
  }

  bool _isExactMatch(Event event) {
    if (event.type == type && event.main == main && event.sub == sub) {
      return true;
    }
    return false;
  }

  bool _isSupersetOf(Event event) {
    if (event.type == type && event.main == main && sub == null) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    if (sub != null) {
      return '${type}_event_${main}_${sub}';
    }
    return '${type}_event_${main}';
  }
}
