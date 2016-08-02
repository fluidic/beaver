import 'dart:io';

import 'package:quiver_collection/collection.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './utils/io.dart';

class YamlConfig extends DelegatingMap implements Config {
  final YamlMap _yamlMap;

  @override
  Map get delegate => _yamlMap;

  YamlConfig(String yaml) : _yamlMap = loadYaml(yaml);

  factory YamlConfig.fromFile(String path) {
    final yaml = readTextFile(path);
    return new YamlConfig(yaml);
  }
}
