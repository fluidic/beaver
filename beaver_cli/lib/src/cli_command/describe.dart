import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';
import '../util.dart';

class DescribeCommand extends HttpCommand {
  @override
  String get description => 'Describe project.';

  @override
  String get name => 'describe';

  @override
  String get api => '/api/describe';

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

    final url = getApiUrl();
    print(url.toString() + ' will be requested.');

    final data = {'project_name': projectName};

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
        print('Project: ${json['project']['project_name']}');

        print('Configuration:');
        final config = json['project']['config'];
        if (config != null) {
          prettyPrint(config, _indent);
        } else {
          print('${_indent}nothing.');
        }

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
