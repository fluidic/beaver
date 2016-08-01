import './base.dart';

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

  DefaultContext(this._config, this._logger, this._partMap);
}
