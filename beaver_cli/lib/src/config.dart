import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

String _userHome() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

getConfig() {
  var file = new File('beaver-config.yaml');
  if (!file.existsSync()) {
    file = new File(path.join(_userHome(), '.beaver-config.yaml'));
    if (!file.existsSync()) {
      return null;
    }
  }
  return loadYaml(file.readAsStringSync());
}
