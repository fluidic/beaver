import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../exit_codes.dart';
import './http.dart';
import '../util.dart';

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

  static const String _indent = '    ';

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
      if (projectName != config['project_name']) {
        print('project_names are different.');
        exit(exitCodeError);
      }
      data.addAll({'config': config.toString()});
    }

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    request.write(JSON.encode(data));
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    if (argResults['json']) {
      print(responseBody);
    } else {
      final json = JSON.decode(responseBody);
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
