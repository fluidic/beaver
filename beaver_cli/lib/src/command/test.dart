import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

class TestCommand extends HttpCommand {
  @override
  String get description => 'Test the trigger.';

  @override
  String get name => 'test';

  TestCommand() : super() {
    argParser.addOption('trigger-type',
        abbr: 't', defaultsTo: 'github', help: 'Trigger\'s type to be tested.');

    argParser.addOption('trigger-name', abbr: 'n', callback: (value) {
      if (value == null) {
        print('trigger name is required.');
        exitWithHelpMessage();
      }
    }, help: 'Trigger\'s name to be tested.');

    argParser.addOption('event',
        abbr: 'e', defaultsTo: 'create', help: 'Event will be sent.');

    argParser.addOption('data', abbr: 'd', callback: (value) {
      if (value == null) {
        print('data is required.');
        exitWithHelpMessage();
      }
    }, help: 'Data will be sent as POST data.');

    argParser.addOption('data-format',
        abbr: 'f', defaultsTo: 'json', help: 'Data\'s format.');
  }

  @override
  String get api => '/' + projectName + '/' + argResults['trigger-name'];

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

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers
        .add('Content-Type', 'application/' + argResults['data-format']);
    if (argResults['trigger-type'] == 'github') {
      request.headers.add('X-GitHub-Event', argResults['event']);
    }
    request.write(argResults['data']);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
