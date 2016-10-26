import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

main(List<String> args) async {
  print('beaver-ci started.');

  final urlPath = Uri.parse(args[0]);
  final headers = JSON.decode(args[1]) as Map<String, String>;
  final data = JSON.decode(args[2]) as Map<String, Object>;

  print(urlPath);
  print(headers);
  print(data);

  // FIXME: Don't hardcode.
  final beaverStore = await getBeaverStore(StorageServiceType.gCloud,
      config: {'cloud_project_name': 'beaver-ci', 'zone': 'us-central1-a'});

  final firstPath = urlPath.pathSegments.first;
  final lastPath = urlPath.pathSegments.last;

  var response;
  if (firstPath == 'api') {
    initApiHandler(beaverStore);
    response = await _apiHandler(lastPath, data);
  } else {
    initTriggerHandler(beaverStore);
    response = await _triggerHandler(firstPath, lastPath, headers, data);
  }

  print('response: ${JSON.encode(response)}');
}

Future _apiHandler(String api, Map<String, Object> data) async {
  var result;
  try {
    final ret = await apiHandler(api, data);
    result = {'status': 'success'}..addAll(ret);
  } catch (e) {
    print(e);
    result = {'statuc': 'failure', 'reason': e.toString()};
  }

  return result;
}

Future _triggerHandler(String projectName, String triggerName,
    Map<String, String> headers, Map<String, Object> data) async {
  var result;
  try {
    final trigger = new Trigger(triggerName, headers, data);
    final buildNumber = await triggerHandler(trigger, projectName);
    result = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    print(e);
    result = {'status': 'failure', 'reason': e.toString()};
  }

  return result;
}
