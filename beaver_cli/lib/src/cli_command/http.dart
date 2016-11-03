import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../config.dart';
import '../exit_codes.dart';

abstract class HttpCommand extends Command {
  String get api;
  String host;
  int port;
  bool secure;
  String pathPrefix;

  HttpCommand() : super() {
    argParser.addOption('host', abbr: 'H', callback: (value) {
      if (value == null) {
        host = getConfig('server', 'host');
      } else {
        host = value;
      }

      if (host == null) {
        print('host is required.');
        exitWithHelpMessage();
      }
    }, help: 'Host will be requested.');

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

  Uri getApiUrl({String additionalPath: ''}) => new Uri(
      scheme: secure ? 'https' : 'http',
      host: host,
      port: port,
      path: '${pathPrefix}${api}${additionalPath}');

  String _getServerUrlAsString() => new Uri(
          scheme: secure ? 'https' : 'http',
          host: host,
          port: port,
          path: '${pathPrefix}')
      .toString();

  String addServerUrlToEndpoints(String response) {
    final json = JSON.decode(response);
    final endpoints = json['endpoints'];
    if (endpoints != null) {
      final serverUrl = _getServerUrlAsString();
      (endpoints as List).forEach((endpoint) {
        endpoint['endpoint'] = serverUrl + endpoint['endpoint'];
      });
    }
    return JSON.encode(json);
  }

  void exitWithHelpMessage() {
    print(argParser.usage);
    exit(exitCodeError);
  }
}
