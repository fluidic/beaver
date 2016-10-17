import 'dart:async';

import 'package:beaver_gcloud/beaver_gcloud.dart';

import './base.dart';

class GCloudContext extends GCloudBase implements Context {
  final Config _config;
  final Logger _logger;
  final Map<String, ContextPart> _partMap;

  @override
  Config get config => _config;

  @override
  Logger get logger => _logger;

  @override
  ContextPart getPart(String name) => _partMap[name];

  GCloudContext(this._config, this._logger, this._partMap);

  Future<Null> setUp() => super.init(
      _config.cloudSettings['project_name'], _config.cloudSettings['zone']);
}
