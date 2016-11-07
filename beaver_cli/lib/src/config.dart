import 'dart:io';

import 'package:beaver_utils/beaver_utils.dart';
import 'package:yaml/yaml.dart';

dynamic getConfig(String key1, [String key2]) {
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
  final file = _getConfigFile();
  if (file == null) {
    return null;
  }
  return loadYaml(file.readAsStringSync());
}

void setConfig(String key, Map map) {
  final config = _dumpToYaml(key, map);
  _saveConfigFile(config);
}

void _saveConfigFile(String config) {
  var file = _getConfigFile();
  if (file == null) {
    file = new File(beaverGlobalConfigPath);
    file.createSync();
  }

  file.writeAsStringSync(config);
}

const String _indent = '  ';
String _dumpToYaml(String key, Map map) {
  final sb = new StringBuffer('$key:\n');
  map.forEach((key, value) {
    sb.writeln('$_indent$key: $value');
  });
  return sb.toString();
}

File _getConfigFile() {
  var file = new File(beaverLocalConfigPath);
  if (!file.existsSync()) {
    file = new File(beaverGlobalConfigPath);
    if (!file.existsSync()) {
      return null;
    }
  }
  return file;
}
