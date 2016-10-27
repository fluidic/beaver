import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

class ListCommand extends HttpCommand {
  @override
  String get description => 'List projects.';

  @override
  String get name => 'list';

  ListCommand() : super() {}

  @override
  String get api => '/api/list';

  @override
  Future<Null> run() async {
    final url = getServerUrl();
    print(url.toString() + ' will be requested.');

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    if (argResults['json']) {
      print(responseBody);
    } else {
      final json = JSON.decode(responseBody);
      if (json['status'] == 'success') {
        final projectNames = json['project_names'] as List;
        projectNames.forEach((projectName) => print(projectName));
      } else {
        print(json['reason']);
      }
    }
  }
}
