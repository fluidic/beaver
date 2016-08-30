import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

class UploadCommand extends Command {
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
        exit(0);
      }
    }, help: 'The config file is uploaded to this project.');
  }

  String get api => '/api/upload';

  @override
  Future<Null> run() async {
    final config = new File(argResults['config-file']).readAsStringSync();
    final data =
        JSON.encode({'id': argResults['project-id'], 'config': config});

    final httpClient = new HttpClient();
    // FIXME: Don't hardcode.
    final request =
        await httpClient.open('POST', 'localhost', 8081, api);
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
