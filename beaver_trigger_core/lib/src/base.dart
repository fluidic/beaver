import 'dart:async';

import 'package:uuid/uuid.dart';

class Context {
  final TriggerConfigStore triggerConfigStore;

  Context(this.triggerConfigStore);
}

abstract class EventDetector {
  String get event;
}

enum SourceType { git, github, gCloudPubSub, awsSNS }

enum TriggerType { special, http, gCloudPubSub, awsSNS }

class TriggerConfig {
  String id;
  SourceType sourceType;
  Uri sourceUrl;
  TriggerType triggerType;
  String token;
  int interval;

  TriggerConfig(this.id, this.sourceType, this.sourceUrl, this.triggerType,
      this.token, this.interval);

  @override
  String toString() {
    final buffer = new StringBuffer('TriggerConfig { \n');
    buffer
      ..write('id: ${id}\n')
      ..write('sourceType: ${sourceType}\n')
      ..write('sourceUrl: ${sourceUrl}\n')
      ..write('triggerType: ${triggerType}\n')
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

Future<String> setTriggerConfig(Context context, SourceType sourceType,
    Uri sourceUrl, TriggerType triggerType,
    {String token, int interval}) async {
  final id = new Uuid().v1();

  final triggerConfig = new TriggerConfig(
      id, sourceType, sourceUrl, triggerType, token, interval);
  final success = await context.triggerConfigStore.save(triggerConfig);

  if (!success) {
    throw new Exception('TriggerConfig is not saved.');
  }

  return id;
}

Future<TriggerConfig> getTriggerConfig(Context context, String id) {
  return context.triggerConfigStore.load(id);
}
