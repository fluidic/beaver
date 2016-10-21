import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

String _userHome() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

getConfig(String key1, [String key2]) {
  final config = _loadConfigFile();

  if (config == null) {
    return null;
  }

  if (key1 != null && key2 == null) {
    return config[key1];
  }

  return config[key1][key2];
}

YamlMap _loadConfigFile() {
  var file = new File('beaver-config.yaml');
  if (!file.existsSync()) {
    file = new File(path.join(_userHome(), '.beaver-config.yaml'));
    if (!file.existsSync()) {
      return null;
    }
  }
  return loadYaml(file.readAsStringSync());
}
