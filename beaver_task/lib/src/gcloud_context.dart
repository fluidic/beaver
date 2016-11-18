import 'dart:async';
import 'dart:mirrors';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:logging/logging.dart';

import './annotation.dart';
import './base.dart';
import './logger.dart';

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

  static Future<GCloudContext> create(Config config) async {
    final logger = new BeaverLogger();
    final partMap = await _createContextPartMap(config);
    final context = new GCloudContext._internal(config, logger, partMap);
    await context.setUp();

    return context;
  }

  GCloudContext._internal(this._config, this._logger, this._partMap);

  Future<Null> setUp() => super.init(
      _config.cloudSettings['project_name'], _config.cloudSettings['zone']);
}

Future<Map<String, ContextPart>> _createContextPartMap(Config config) async {
  Map<String, ClassMirror> contextPartClassMap =
      queryNameClassMapByAnnotation(ContextPartClass);
  _dumpClassMap('List of ContextPart classes:', contextPartClassMap);

  final partMap = {};
  contextPartClassMap.forEach((String name, ClassMirror contextParClass) {
    partMap[name] = newInstance('', contextParClass, []);
  });
  await Future
      .wait(partMap.values.map((ContextPart part) => part.setUp(config)));
  return partMap;
}

void _dumpClassMap(String prefix, Map<String, ClassMirror> taskClassMap) {
  print(prefix);
  taskClassMap.forEach((name, cm) {
    print('  $name -> ${cm.qualifiedName}');
  });
}
