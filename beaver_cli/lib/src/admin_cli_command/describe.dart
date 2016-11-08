import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';

import '../exit_codes.dart' as exit_codes;

class DescribeCommand extends Command {
  @override
  String get description => 'Describe the beaver CI env';

  @override
  String get name => 'describe';

  @override
  Future<Null> run() async {
    if (argResults.rest.length != 1) {
      print('Specify site id to describe.');
      printUsage();
      exit(exit_codes.usage);
    }
    final siteId = argResults.rest[0];

    final config = await readYamlFile(beaverAdminConfigPath);
    if (config == null || config['sites'] == null) return;

    for (final site in config['sites']) {
      if (site['site_id'] == siteId) {
        print(toYamlString(site));
      }
    }
  }
}
