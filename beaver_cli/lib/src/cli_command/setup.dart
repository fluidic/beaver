import 'dart:async';

import 'package:args/command_runner.dart';

import '../config.dart';

class SetupCommand extends Command {
  @override
  String get description => 'Setup API server information.';

  @override
  String get name => 'setup';

  SetupCommand() : super() {}

  @override
  Future<Null> run() async {
    String address;
    if (argResults.rest.length == 1) {
      address = argResults.rest[0];
    } else {
      print('API server address is required.');
    }

    Uri server = Uri.parse(address);
    final map = {
      'host': server.host,
      'secure': server.scheme == 'https' ? true : false
    };
    if (server.hasPort) {
      map.addAll({'port': server.port});
    }
    if (!server.hasEmptyPath) {
      map.addAll({'path_prefix': server.path});
    }

    setConfig('server', map);

    print('Done successfully.');
  }
}
