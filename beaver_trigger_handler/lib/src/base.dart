import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:logging/logging.dart' as logging;

class Context {
  final logging.Logger logger;
  final BeaverStore beaverStore;

  Context(this.logger, this.beaverStore);
}

class Trigger {
  final String name;
  final Map<String, String> headers;
  final Map<String, Object> data;

  Trigger(this.name, this.headers, this.data);
}

abstract class TriggerParser {
  ParsedTrigger parse(Context context, Trigger trigger);
}

class TriggerParserClass {
  final String name;
  const TriggerParserClass(this.name);
}

class ParsedTrigger {
  final String event;
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
      // FIXME: Don't hardcode.
      if (!keys.startsWith('.')) {
        if (keys == 'url') {
          return this.url;
        }
        throw new Exception('ParsedTrigger doesn\'t have ${keys} field.');
      }
      keys = keys.split('.');
      keys = keys.sublist(1);
    } catch (_) {
      throw new Exception('Wrong format for a trigger data: ${str}');
    }

    try {
      dynamic value = data;
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
