import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

import '../config.dart';

class RegisterCommand extends Command {
  @override
  String get description => 'Register new project and upload config file.';

  @override
  String get name => 'register';

  RegisterCommand() : super() {
    // FIXME: Many command uses the same options. Can remove the duplication?
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
        port = 80;
      } else {
        port = int.parse(portStr);
      }
    }, help: 'Port number will be used to request.');

    argParser.addOption('config-file',
        abbr: 'c',
        defaultsTo: './beaver.yaml',
        help: 'Config file will be uploaded.');
  }

  String get api => '/api/register';
  String address;
  int port;

  @override
  Future<Null> run() async {
    final config =
        loadYaml(new File(argResults['config-file']).readAsStringSync());

    final httpClient = new HttpClient();
    var request = await httpClient.open('POST', address, port, api);
    request.headers.add('Content-Type', 'application/json');
    var data = JSON.encode(
        {'project': config['project_name'], 'config': config.toString()});
    request.write(data);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
