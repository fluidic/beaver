import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

String _userHome() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

String _globalConfigFile() => path.join(_userHome(), '.beaver-config.yaml');

String _localConfigFile() => 'beaver-config.yaml';

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

_saveConfigFile(String config) {
  var file = _getConfigFile();
  if (file == null) {
    file = new File(_globalConfigFile());
    file.createSync();
  }

  file.writeAsStringSync(config);
}

const String _indent = '  ';
_dumpToYaml(String key, Map map) {
  final sb = new StringBuffer('${key}:\n');
  map.forEach((key, value) {
    sb.writeln('${_indent}${key}: ${value}');
  });
  return sb.toString();
}

File _getConfigFile() {
  var file = new File(_localConfigFile());
  if (!file.existsSync()) {
    file = new File(_globalConfigFile());
    if (!file.existsSync()) {
      return null;
    }
  }
  return file;
}
