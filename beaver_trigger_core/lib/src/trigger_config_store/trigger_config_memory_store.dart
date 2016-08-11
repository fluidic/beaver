import 'dart:async';

import '../base.dart';

class TriggerConfigMemoryStore implements TriggerConfigStore {
  Map<String, TriggerConfig> _config = {};

  @override
  Future<TriggerConfig> load(Uri endpoint) async {
    final key = endpoint.pathSegments.last;
    if (!_config.containsKey(key)) {
      throw new Exception('endpoint \'${endpoint}\' does not exist.');
    }

    return _config[key];
  }

  @override
  Future<bool> save(TriggerConfig triggerConfig) async {
    final key = triggerConfig.endpoint.pathSegments.last;
    _config[key] = triggerConfig;
    return true;
  }
}
