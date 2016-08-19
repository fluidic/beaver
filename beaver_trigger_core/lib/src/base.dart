import 'dart:async';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

class Context {
  final Logger logger;
  final TriggerConfigStore triggerConfigStore;

  Context(this.logger, this.triggerConfigStore);
}

abstract class EventDetector {
  String get event;
}

enum SourceType { git, github, gCloudPubSub, awsSNS }

class TriggerConfig {
  String id;
  SourceType sourceType;
  Uri sourceUrl;
  String token;
  int interval;

  TriggerConfig(
      this.id, this.sourceType, this.sourceUrl, this.token, this.interval);

  @override
  String toString() {
    final buffer = new StringBuffer('TriggerConfig { \n');
    buffer
      ..write('id: ${id}\n')
      ..write('sourceType: ${sourceType}\n')
      ..write('sourceUrl: ${sourceUrl}\n')
      ..write('token: ${token}\n')
      ..write('interval: ${interval}\n');
    buffer.write('}');
    return buffer.toString();
  }
}

abstract class TriggerConfigStore {
  Future<TriggerConfig> load(String id);
  Future<bool> save(TriggerConfig triggerConfig);
}

Future<String> setTriggerConfig(
    Context context, SourceType sourceType, Uri sourceUrl,
    {String token, int interval}) async {
  final id = new Uuid().v1();

  final triggerConfig =
      new TriggerConfig(id, sourceType, sourceUrl, token, interval);
  final success = await context.triggerConfigStore.save(triggerConfig);

  if (!success) {
    throw new Exception('TriggerConfig is not saved.');
  }

  return id;
}

Future<TriggerConfig> getTriggerConfig(Context context, String id) {
  return context.triggerConfigStore.load(id);
}
