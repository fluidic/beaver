import 'dart:async';

import './base.dart';
import './logger.dart';

class DefaultContext implements Context {
  final Config _config;
  final Logger _logger;
  final Map<String, ContextPart> _partMap;

  @override
  Config get config => _config;

  @override
  Logger get logger => _logger;

  @override
  ContextPart getPart(String name) => _partMap[name];

  static Future<Context> create(Config config,
      {Logger logger: const NoneLogger(),
      Iterable<ContextPart> parts: const []}) async {
    final memoryLogger = new MemoryLogger(logger);

    Map<String, ContextPart> partMap = {};
    final futures = parts.map((ContextPart part) {
      partMap[part.name] = part;
      return part.setUp(config);
    });
    await Future.wait(futures);

    return new DefaultContext._internal(config, memoryLogger, partMap);
  }

  DefaultContext._internal(this._config, this._logger, this._partMap);
}
