import 'dart:io';

import 'package:args/command_runner.dart';

import '../config.dart';

abstract class HttpCommand extends Command {
  String get api;
  String address;
  int port;
  bool secure;
  String pathPrefix;

  HttpCommand() : super() {
    argParser.addOption('address', abbr: 'A', callback: (value) {
      if (value == null) {
        final config = getConfig();
        address = config['server']['address'];
      } else {
        address = value;
      }

      if (address == null) {
        print('address is required.');
        exit(0);
      }
    }, help: 'Address will be requested.');

    argParser.addOption('port', abbr: 'P', callback: (value) {
      if (value == null) {
        final config = getConfig();
        port = config['server']['port'];
      } else {
        port = value;
      }

      if (port == null) {
        final config = getConfig();
        if (config['server']['secure']) {
          port = 443;
        } else {
          port = 80;
        }
      }
    }, help: 'Port number will be used to request.');

    argParser.addFlag('secure', abbr: 'S', callback: (value) {
      final config = getConfig();
      secure = config['server'][secure] ?? false;
    }, help: 'If \'true\', HTTPS will be used.');

    argParser.addOption('path-prefix', abbr: 'a', callback: (value) {
      if (value == null) {
        final config = getConfig();
        pathPrefix = config['server']['path_prefix'] ?? '';
      }
    }, help: 'Path prefix.');
  }

  Uri getServerUrl() => new Uri(
      scheme: secure ? 'https' : 'http',
      host: address,
      port: port,
      path: '${pathPrefix}${api}');
}

