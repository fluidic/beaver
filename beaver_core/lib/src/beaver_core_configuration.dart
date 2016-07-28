// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:quiver_collection/collection.dart';
import 'package:yaml/yaml.dart';

import './beaver_core_base.dart';

class YamlConfiguration extends DelegatingMap implements Configuration {
  final YamlMap _yamlMap;

  @override
  Map get delegate => _yamlMap;

  YamlConfiguration(String yaml) : _yamlMap = loadYaml(yaml);

  factory YamlConfiguration.fromFile(String path) {
    final yaml = new File(path).readAsStringSync();
    return new YamlConfiguration(yaml);
  }
}
