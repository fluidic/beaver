import 'package:quiver_collection/collection.dart';
import 'package:yaml/yaml.dart';

class Config extends DelegatingMap {
  final YamlMap _yaml;

  Config(String yaml) : _yaml = loadYaml(yaml);

  @override
  Map get delegate => _yaml;
}
