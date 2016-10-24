import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import './http.dart';

class CreateCommand extends HttpCommand {
  @override
  String get description => 'Create new project and upload config file.';

  @override
  String get name => 'create';

  CreateCommand() : super() {
    argParser.addOption('config-file',
        abbr: 'c', help: 'Config file will be uploaded.');
  }

  @override
  String get api => '/api/create';

  String projectName;

  @override
  Future<Null> run() async {
    if (argResults.rest.length == 1) {
      projectName = argResults.rest[0];
    } else {
      print('project_name is required.');
      exitWithHelpMessage();
    }

    final url = getServerUrl();
    print(url.toString() + ' will be requested.');

    final data = {'project_name': projectName};
    if (argResults['config-file'] != null) {
      final config =
          loadYaml(new File(argResults['config-file']).readAsStringSync());
      data.addAll({'config': config.toString()});
    }

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    request.write(JSON.encode(data));
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
