import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

class ResultCommand extends HttpCommand {
  @override
  String get description => 'Show the result of the build.';

  @override
  String get name => 'result';

  ResultCommand() : super() {
    argParser.addOption('project-id', abbr: 'p', callback: (value) {
      if (value == null) {
        print('project-id is required.');
        exit(0);
      }
    }, help: 'Project ID.');

    argParser.addOption('build-number', abbr: 'b', callback: (value) {
      if (value == null) {
        print('build-number is required.');
        exit(0);
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
        exit(0);
      }
    }, help: 'Number of results to output.');
  }

  @override
  String get api => '/api/result';

  @override
  Future<Null> run() async {
    final data = JSON.encode({
      'id': argResults['project-id'],
      'build_number': argResults['build-number'],
      'format': argResults['format'],
      'count': argResults['count']
    });

    final httpClient = new HttpClient();
    var request = await httpClient.openUrl('POST', getServerUrl());
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    final jsonBody = JSON.decode(responseBody);
    if (jsonBody['status'] == 'success') {
      print(jsonBody['result'].toString());
    } else {
      print(responseBody);
    }
  }
}
