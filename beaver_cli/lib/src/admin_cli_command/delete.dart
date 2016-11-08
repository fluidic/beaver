import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';

import '../exit_codes.dart';

final gcloudCli = new CommandWrapper('gcloud');

class DeleteCommand extends Command {
  @override
  String get description => 'Delete a beaver CI env';

  @override
  String get name => 'delete';

  Future<Null> deleteFunction(String siteId) async {
    final functionName = 'beaver-functions-$siteId';
    await gcloudCli
        .run(['alpha', 'functions', 'delete', functionName], stdin: ['y']);
  }

  @override
  Future<Null> run() async {
    if (argResults.rest.length != 1) {
      print('Specify site id to describe.');
      printUsage();
      exit(exitCodeError);
    }
    final siteId = argResults.rest[0];

    await createFileIfNotExist(beaverAdminConfigPath);
    final config = await readYamlFile(beaverAdminConfigPath);
    if (config['sites'] == null) {
      print('$siteId does not exist');
      exit(exitCodeError);
    }
    var foundSite;
    for (final site in config['sites']) {
      if (site['site_id'] == siteId) {
        config['sites'].remove(site);
        foundSite = site;
        break;
      }
    }
    if (foundSite == null) {
      print('$siteId does not exist');
      exit(exitCodeError);
    }
    config['sites'].remove(foundSite);
    await deleteFunction(siteId);
    await writeYamlFile(beaverAdminConfigPath, config);
    print('Deleted $siteId');
  }
}
