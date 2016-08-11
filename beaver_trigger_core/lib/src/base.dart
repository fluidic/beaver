import 'dart:async';

import 'package:uuid/uuid.dart';

abstract class Context {
  final Uri url;
  final TriggerConfigStore triggerConfigStore;

  Context(this.url, this.triggerConfigStore);
}

enum SourceType { git, github, gCloudPubSub, awsSNS }

enum TriggerType { special, http, gCloudPubSub, awsSNS }

class TriggerConfig {
  Uri endpoint;
  SourceType sourceType;
  Uri sourceUrl;
  TriggerType triggerType;
  String token;
  int interval;

  TriggerConfig(this.endpoint, this.sourceType, this.sourceUrl,
      this.triggerType, this.token, this.interval);

  @override
  String toString() {
    final buffer = new StringBuffer('TriggerConfig { \n');
    buffer
      ..write('endpoint: ${endpoint}\n')
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
  Future<TriggerConfig> load(Uri endpoint);
  Future<bool> save(TriggerConfig triggerConfig);
}

Future<Uri> setTriggerConfig(Context context, SourceType sourceType,
    Uri sourceUrl, TriggerType triggerType,
    {String token, int interval}) async {
  final id = new Uuid().v1();
  final endpoint = Uri.parse(context.url.toString() + '/' + id);

  final triggerConfig = new TriggerConfig(
      endpoint, sourceType, sourceUrl, triggerType, token, interval);
  final success = await context.triggerConfigStore.save(triggerConfig);

  if (!success) {
    throw new Exception('TriggerConfig is not saved.');
  }

  return endpoint;
}

Future<TriggerConfig> getTriggerConfig(Context context, Uri endpoint) {
  return context.triggerConfigStore.load(endpoint);
}
