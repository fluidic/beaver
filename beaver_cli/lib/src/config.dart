import 'dart:io';

import 'package:ini/ini.dart';

Config getConfig() {
  return _loadConfig();
}

Config _loadConfig() {
  var file = new File('./.beaverconfig');
  if (!file.existsSync()) {
    file = new File('~/.beaverconfig');
    if (!file.existsSync()) {
      return null;
    }
  }
  final ini = file.readAsStringSync();
  return new Config.fromString(ini);
}
