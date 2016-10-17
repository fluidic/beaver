import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:path/path.dart' as path;

main(List<String> args) async {
  print('beaver-ci started.');

  final urlPath = args[0];
  final headers = JSON.decode(args[1]) as Map<String, String>;
  final data = JSON.decode(args[2]) as Map<String, Object>;

  print(urlPath);
  print(headers);
  print(data);

  // FIXME: Don't hardcode.
  final beaverStore = await getBeaverStore(StorageServiceType.gCloud,
      config: {'cloud_project_name': 'beaver-ci', 'zone': 'us-central1-a'});

  var response;
  if (urlPath.startsWith('/api')) {
    initApiHandler(beaverStore);
    response = await _apiHandler(path.basename(urlPath), data);
  } else if (urlPath.startsWith('/github')) {
    initTriggerHandler(beaverStore);
    response =
        await _gitHubTriggerHandler(path.basename(urlPath), headers, data);
  } else {
    throw new Exception('Not Found.');
  }

  print('response: ${JSON.encode(response)}');
}

Future _apiHandler(String api, Map<String, Object> data) async {
  var status = 'success';
  Map<String, Object> result;
  try {
    result = await apiHandler(api, data);
  } catch (e) {
    print(e);
    status = 'failure';
    result = {'reason': e.toString()};
  }

  return {'status': status}..addAll(result);
}

Future _gitHubTriggerHandler(String projectId, Map<String, String> headers,
    Map<String, Object> data) async {
  var result;
  try {
    final trigger = new Trigger('github', headers, data);
    final buildNumber = await triggerHandler(trigger, projectId);
    result = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    print(e);
    result = {'status': 'failure', 'reason': e.toString()};
  }

  return result;
}
