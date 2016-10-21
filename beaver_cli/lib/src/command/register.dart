import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import './http.dart';

class RegisterCommand extends HttpCommand {
  @override
  String get description => 'Register new project and upload config file.';

  @override
  String get name => 'register';

  RegisterCommand() : super() {
    argParser.addOption('config-file',
        abbr: 'c',
        defaultsTo: './beaver.yaml',
        help: 'Config file will be uploaded.');
  }

  @override
  String get api => '/api/register';

  @override
  Future<Null> run() async {
    final url = getServerUrl();
    print(url.toString() + ' will be requested.');

    final config =
        loadYaml(new File(argResults['config-file']).readAsStringSync());

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    final data = JSON.encode(
        {'project': config['project_name'], 'config': config.toString()});
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
