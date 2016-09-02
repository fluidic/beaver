import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ini/ini.dart';
import 'package:yaml/yaml.dart';

class RegisterCommand extends Command {
  @override
  String get description => 'Register new project and upload config file.';

  @override
  String get name => 'register';

  RegisterCommand(Config config) : super() {
    address = config.get('server', 'address');
    port = int.parse(config.get('server', 'port'));

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
