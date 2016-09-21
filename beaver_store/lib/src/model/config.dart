import 'package:beaver_task/beaver_task.dart';
import 'package:quiver_collection/collection.dart';
import 'package:yaml/yaml.dart';

class YamlConfig extends DelegatingMap implements Config {
  final YamlMap _yaml;

  YamlConfig(String yaml) : _yaml = loadYaml(yaml);

  @override
  Map get delegate => _yaml;

  @override
  String toString() => _yaml.toString();
}
