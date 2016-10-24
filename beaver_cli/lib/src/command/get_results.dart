import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

class GetResultsCommand extends HttpCommand {
  @override
  String get description => 'Show the result of the builds.';

  @override
  String get name => 'get-results';

  GetResultsCommand() : super() {
    argParser.addOption('build-number', abbr: 'b', callback: (value) {
      if (value == null) {
        print('build-number is required.');
        exitWithHelpMessage();
      }
    }, help: 'Build number to be got.');

    argParser.addOption('format',
        abbr: 'f',
        defaultsTo: 'text',
        allowed: ['text', 'html'],
        help: 'The result format.');

    argParser.addOption('count', abbr: 'n', defaultsTo: '1', callback: (value) {
      if (int.parse(value, onError: (source) => -1) <= 0) {
        print('The option -n requires a positive integer.');
        exitWithHelpMessage();
      }
    }, help: 'Number of results to output.');
  }

  @override
  String get api => '/api/get-results';

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

    final data = JSON.encode({
      'project_name': projectName,
      'build_number': argResults['build-number'],
      'format': argResults['format'],
      'count': argResults['count']
    });

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    final jsonBody = JSON.decode(responseBody);
    if (jsonBody['status'] == 'success') {
      print(jsonBody['result'].toString());
    } else {
      print(responseBody);
    }
  }
}
