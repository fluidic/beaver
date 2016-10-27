import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import './http.dart';
import '../util.dart';

class UploadCommand extends HttpCommand {
  @override
  String get description => 'Upload config file for the existing project.';

  @override
  String get name => 'upload';

  UploadCommand() : super() {
    argParser.addOption('config-file',
        abbr: 'c',
        defaultsTo: './beaver.yaml',
        help: 'Config file will be uploaded.');
  }

  @override
  String get api => '/api/upload';

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

    final config = new File(argResults['config-file']).readAsStringSync();
    final yaml = loadYaml(config);
    if (projectName != yaml['project_name']) {
      print('project_names are different.');
      exit(0);
    }
    final data = JSON.encode({'project_name': projectName, 'config': config});

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', getServerUrl());
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    if (argResults['json']) {
      print(responseBody);
    } else {
      final json = JSON.decode(responseBody);
      if (json['status'] == 'success') {
        print('Endpoints: ');
        final endpoints = json['endpoints'];
        if (endpoints != null) {
          prettyPrint(endpoints, _indent);
        } else {
          print('${_indent}nothing.');
        }
      } else {
        print(json['reason']);
      }
    }
  }
}
