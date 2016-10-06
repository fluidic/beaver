import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:logging/logging.dart' as logging;

import './trigger_parser.dart';

class Context {
  final logging.Logger logger;
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
    // FIXME: a better way?
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

class ParsedTrigger {
  final Event event;
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

    // FIXME: a better way?
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

enum TaskInstanceStatus { success, failure }

class TaskInstanceRunResult {
  final TaskInstanceStatus status;
  final TaskRunResult taskRunResult;

  TaskInstanceRunResult(this.status, this.taskRunResult);

  @override
  String toString() {
    var taskInstanceStatus = 'success';
    if (status != TaskInstanceStatus.success) {
      taskInstanceStatus = 'failure';
    }

    var taskStatus = 'success';
    if (taskRunResult.status != TaskStatus.Success) {
      taskStatus = 'failure';
    }

    final buffer = new StringBuffer();
    buffer
      ..writeln('status: ${taskInstanceStatus}')
      ..writeln('TaskRunResult')
      ..writeln('status: ${taskStatus}')
      ..writeln('config: ${taskRunResult.config.toString()}')
      ..writeln('log: ${taskRunResult.log}');
    return buffer.toString();
  }
}

class TriggerResult {
  final Project project;
  final int buildNumber;
  final Trigger trigger;
  final ParsedTrigger parsedTrigger;
  final Map<String, Object> taskInstance;
  final TaskInstanceRunResult taskInstanceRunResult;

  TriggerResult(this.project, this.buildNumber, this.trigger,
      this.parsedTrigger, this.taskInstance, this.taskInstanceRunResult);
}
