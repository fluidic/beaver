import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../config.dart';

class ResultCommand extends Command {
  @override
  String get description => 'Show the result of the build.';

  @override
  String get name => 'result';

  ResultCommand() : super() {
    argParser.addOption('address', abbr: 'A', callback: (value) {
      if (value == null) {
        final config = getConfig();
        address = config?.get('server', 'address');
      } else {
        address = value;
      }

      if (address == null) {
        print('address is required.');
        exit(0);
      }
    }, help: 'Address will be requested.');

    argParser.addOption('port', abbr: 'P', callback: (value) {
      var portStr;
      if (value == null) {
        final config = getConfig();
        portStr = config?.get('server', 'port');
      } else {
        portStr = value;
      }

      if (portStr == null) {
        port = 80;
      } else {
        port = int.parse(portStr);
      }
    }, help: 'Port number will be used to request.');

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
  }

  String get api => '/api/result';
  String address;
  int port;

  @override
  Future<Null> run() async {
    final data = JSON.encode({
      'id': argResults['project-id'],
      'build_number': argResults['build-number'],
      'format': argResults['format']
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
