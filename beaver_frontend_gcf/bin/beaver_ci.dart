import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:path/path.dart' as path;

main(List<String> args) async {
  print('beaver-ci started.');

  final urlPath = args[0];
  final headers = JSON.decode(args[1]);
  final data = JSON.decode(args[2]);

  print(urlPath);
  print(headers);
  print(data);

  var response;
  if (urlPath.startsWith('/api')) {
    response = await _apiHandler(path.basename(urlPath), data);
  } else if (urlPath.startsWith('/github')) {
    response =
        await _githubTriggerHandler(path.basename(urlPath), headers, data);
  } else {
    throw new Exception('Not Found.');
  }

  print('response: ${JSON.encode(response)}');
}

Future _apiHandler(String api, Map<String, Object> data) async {
  var status = 'success';
  var result;
  try {
    result = await apiHandler(api, data);
  } catch (e) {
    print(e);
    status = 'failure';
    result = {'reason': e.toString()};
  }

  return {'status': status}..addAll(result);
}

Future _githubTriggerHandler(String projectId, Map<String, String> headers,
    Map<String, Object> data) async {
  var status = 'success';
  var buildNumber;
  try {
    final trigger = new Trigger('github', headers, data);
    buildNumber = await triggerHandler(trigger, projectId);
  } catch (e) {
    print(e);
    status = 'failure';
  }

  return {'status': status, 'build_number': buildNumber};
}
