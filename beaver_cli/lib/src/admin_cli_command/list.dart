import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:yaml/yaml.dart';

class ListCommand extends Command {
  @override
  String get description => 'List beaver CI envs';

  @override
  String get name => 'list';

  @override
  Future<Null> run() async {
    final contents = await readTextFile(beaverAdminConfigPath);
    final config = loadYaml(contents);
    if (config == null || config['sites'] == null) return;

    for (final site in config['sites']) {
      print(site['site_id']);
    }
  }
}

