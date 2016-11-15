import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../exit_codes.dart' as exit_codes;
import './http.dart';
import '../utils.dart';

class CreateCommand extends HttpCommand {
  @override
  String get description => 'Create new project and upload config file.';

  @override
  String get name => 'create';

  CreateCommand() {
    argParser.addOption('config-file',
        abbr: 'c', help: 'Config file will be uploaded.');
  }

  @override
  String get api => '/api/create';

  static const String _indent = '    ';

  @override
  Future<Null> run() async {
    String projectName;

    if (argResults.rest.length == 1) {
      projectName = argResults.rest[0];
    } else {
      print('project_name is required.');
      exitWithHelpMessage();
    }

    final url = getApiUrl();
    print(url.toString() + ' will be requested.');

    final data = {'project_name': projectName};
    if (argResults['config-file'] != null) {
      final yaml = new File(argResults['config-file']).readAsStringSync();
      final config = loadYaml(yaml);
      if (projectName != config['project_name']) {
        print('project_names are different.');
        exit(exit_codes.data);
      }
      data.addAll({'config': yaml});
    }

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    request.write(JSON.encode(data));
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    final result = addServerUrlToEndpoints(responseBody);
    if (argResults['json']) {
      print(result);
    } else {
      final json = JSON.decode(result);
      if (json['status'] == 'success') {
        print('Created successfully.');

        final endpoints = json['endpoints'];
        if (endpoints != null) {
          print('Endpoints: ');
          prettyPrint(endpoints, _indent);
        }
      } else {
        print(json['reason']);
      }
    }
  }
}
