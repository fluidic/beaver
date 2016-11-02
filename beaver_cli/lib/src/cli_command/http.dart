import 'dart:io';

import 'package:args/command_runner.dart';

import '../config.dart';
import '../exit_codes.dart';

abstract class HttpCommand extends Command {
  String get api;
  String address;
  int port;
  bool secure;
  String pathPrefix;

  HttpCommand() : super() {
    argParser.addOption('address', abbr: 'A', callback: (value) {
      if (value == null) {
        address = getConfig('server', 'address');
      } else {
        address = value;
      }

      if (address == null) {
        print('address is required.');
        exitWithHelpMessage();
      }
    }, help: 'Address will be requested.');

    argParser.addOption('port', abbr: 'P', callback: (value) {
      if (value == null) {
        port = getConfig('server', 'port');
      } else {
        port = int.parse(value);
      }

      if (port == null) {
        if (getConfig('server', 'secure')) {
          port = 443;
        } else {
          port = 80;
        }
      }
    }, help: 'Port number will be used to request.');

    argParser.addFlag('secure', abbr: 'S', callback: (value) {
      secure = getConfig('server', 'secure') ?? false;
    }, help: 'If \'true\', HTTPS will be used.');

    argParser.addOption('path-prefix', abbr: 'a', callback: (value) {
      if (value == null) {
        pathPrefix = getConfig('server', 'path_prefix') ?? '';
      }
    }, help: 'Path prefix.');

    argParser.addFlag('json',
        abbr: 'j', defaultsTo: false, help: 'Print output as a JSON string.');
  }

  Uri getServerUrl({String additionalPath: ''}) => new Uri(
      scheme: secure ? 'https' : 'http',
      host: address,
      port: port,
      path: '${pathPrefix}${api}${additionalPath}');

  void exitWithHelpMessage() {
    print(argParser.usage);
    exit(exitCodeError);
  }
}
