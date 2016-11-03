import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:logging/logging.dart' as logging;
import 'package:parsers/parsers.dart';

class Context {
  final logging.Logger logger;
  final BeaverStore beaverStore;

  Context(this.logger, this.beaverStore);
}

class Trigger {
  final String name;
  final String projectName;
  final Map<String, String> headers;
  final Map<String, Object> payload;

  Trigger(Uri requestUrl, this.headers, this.payload)
      : name = requestUrl.pathSegments.last,
        projectName =
            requestUrl.pathSegments[requestUrl.pathSegments.length - 2];
}

class CloudInfo {
  final String type;
  final String region;
  final String projectName;
  final Uri baseUrl;

  CloudInfo._internal(this.baseUrl, this.type, this.region, this.projectName);

  factory CloudInfo.fromUrl(Uri requestUrl) {
    // TODO: Support the other cloud platforms.
    var type;
    if (requestUrl.host.contains('cloudfunctions.net')) {
      type = 'gcloud';
    } else {
      type = 'local';
    }

    switch (type) {
      case 'gcloud':
        final exp = new RegExp(r'^([^-]+[-][^-]+)[-](.*)\..+\..+$');
        final match = exp.firstMatch(requestUrl.host);
        final region = match.group(1);
        final projectName = match.group(2);
        final url = new Uri(
            scheme: requestUrl.scheme,
            host: requestUrl.host,
            port: requestUrl.port,
            path: requestUrl.pathSegments.first);
        return new CloudInfo._internal(url, type, region, projectName);
      case 'local':
        final url = new Uri(
            scheme: requestUrl.scheme,
            host: requestUrl.host,
            port: requestUrl.port);
        // FIXME: Don't hardcode.
        return new CloudInfo._internal(
            url, 'gcloud', 'us-central1', 'beaver-ci');
      default:
        throw new Exception('Not supported cloud type.');
    }
  }
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
  final Map<String, Object> payload;

  ParsedTrigger(this.event, this.url, this.payload);

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

    var ids;
    try {
      ids = new _TriggerData().start.parse(str)[1];
    } catch (_) {
      throw new Exception('Wrong format for a trigger data: ${str}');
    }

    // FIXME: Improve!
    try {
      var data;
      final fieldName = ids[0];
      switch (fieldName) {
        case 'url':
          data = url;
          break;
        case 'payload':
          data = payload;

          if (ids.length > 1) {
            final keys = ids.sublist(1);
            for (final key in keys) {
              data = data[key];
            }
          }
          break;
        case 'event':
          data = event;
          break;
        default:
          throw new Exception();
      }

      return data;
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
      ..writeln('data: ${payload}');
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

class _TriggerData extends LanguageParsers {
  get prefix => string(ParsedTrigger.triggerDataPrefix);

  get term => (prefix + prop).list;
  get prop => identifier.sepBy1(dot);

  get start => term.between(spaces, eof);
}
