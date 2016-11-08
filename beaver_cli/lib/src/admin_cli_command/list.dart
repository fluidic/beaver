import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';

class ListCommand extends Command {
  @override
  String get description => 'List beaver CI envs';

  @override
  String get name => 'list';

  @override
  Future<Null> run() async {
    final config = await readYamlFile(beaverAdminConfigPath);
    if (config == null || config['sites'] == null) return;

    for (final site in config['sites']) {
      print(site['site_id']);
    }
  }
}
