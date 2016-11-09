import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart' as logging;
import 'package:parsers/parsers.dart';

class Context {
  final logging.Logger logger;
  final BeaverStore beaverStore;
  String status;

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
      throw new Exception('Wrong format for a trigger data: $str');
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
      throw new Exception('No data for a trigger data: $str');
    }
  }

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer
      ..writeln('event: $event')
      ..writeln('url: $url')
      ..writeln('data: $payload');
    return buffer.toString();
  }
}

class _TriggerData extends LanguageParsers {
  Parser get prefix => string(ParsedTrigger.triggerDataPrefix);

  Parser<List> get term => (prefix + prop).list;
  Parser<List> get prop => identifier.sepBy1(dot);

  Parser get start => term.between(spaces, eof);
}
