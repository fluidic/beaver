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
        address = config?.get('server', 'address');
      } else {
        address = value;
      }

      if (address == null) {
        print('address is required.');
        exit(0);
      }
    }, help: 'Address will be requested.');

    argParser.addOption('port', abbr: 'P', callback: (value) {
      var portStr;
      if (value == null) {
        final config = getConfig();
        portStr = config?.get('server', 'port');
      } else {
        portStr = value;
      }

      if (portStr == null) {
        final config = getConfig();
        final secure = config?.get('server', 'secure') == 'true';
        if (secure) {
          port = 443;
        } else {
          port = 80;
        }
      } else {
        port = int.parse(portStr);
      }
    }, help: 'Port number will be used to request.');

    argParser.addFlag('secure', abbr: 'S', callback: (value) {
      final config = getConfig();
      secure = config?.get('server', 'secure') == 'true';
    }, help: 'If \'true\', HTTPS will be used.');

    argParser.addOption('path-prefix', abbr: 'a', callback: (value) {
      if (value == null) {
        final config = getConfig();
        pathPrefix = config?.get('server', 'path_prefix');
      }
    }, help: 'Path prefix.');
  }

  Uri getServerUrl() {
    final url = new StringBuffer();

    if (secure) {
      url.write('https://');
    } else {
      url.write('http://');
    }
    url.write(address);
    url.write(':');
    url.write(port);
    if (pathPrefix != null) {
      url.write(pathPrefix);
    }
    url.write(api);

    return Uri.parse(url.toString());
  }
}
