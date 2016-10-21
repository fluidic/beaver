import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

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

    argParser.addOption('project-id', abbr: 'p', callback: (value) {
      if (value == null) {
        print('project-id is required.');
        exitWithHelpMessage();
      }
    }, help: 'The config file is uploaded to this project.');
  }

  @override
  String get api => '/api/upload';

  @override
  Future<Null> run() async {
    final url = getServerUrl();
    print(url.toString() + ' will be requested.');

    final config = new File(argResults['config-file']).readAsStringSync();
    final data =
        JSON.encode({'id': argResults['project-id'], 'config': config});

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', getServerUrl());
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
