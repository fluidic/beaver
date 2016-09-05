import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ini/ini.dart';

class ResultCommand extends Command {
  @override
  String get description => 'Show the result of the build.';

  @override
  String get name => 'result';

  ResultCommand(Config config) : super() {
    address = config.get('server', 'address');
    port = int.parse(config.get('server', 'port'));

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
  }

  String get api => '/api/result';
  String address;
  int port;

  @override
  Future<Null> run() async {
    final data = JSON.encode({
      'id': argResults['project-id'],
      'build_number': argResults['build-number']
    });

    final httpClient = new HttpClient();
    var request = await httpClient.open('POST', address, port, api);
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    var response = await request.close();
    var responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
