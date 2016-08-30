import 'dart:io';

import 'package:beaver_cli/beaver_cli.dart' as beaver_cli;
import 'package:ini/ini.dart';

main(List<String> arguments) {
  final ini = new File('./.beaverconfig').readAsStringSync();
  final config = new Config.fromString(ini);
  print(
      'Server ${config.get('server', 'address')}:${config.get('server', 'port')} is used.');

  final runner = beaver_cli.getRunner(config);
  runner.run(arguments);
}
