import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

Future<Null> main(List<String> args) async {
  print('beaver-ci started.');

  final requestUrl = Uri.parse(args[0]);
  final headers = JSON.decode(args[1]) as Map<String, String>;
  final data = JSON.decode(args[2]) as Map<String, Object>;

  print(requestUrl);
  print(headers);
  print(data);

  // FIXME: Don't hardcode.
  final beaverStore = await getBeaverStore(StorageServiceType.gCloud,
      config: {'cloud_project_name': 'beaver-ci', 'zone': 'us-central1-a'});

  var response;
  if (_isApiRequest(requestUrl)) {
    initApiHandler(beaverStore);
    response = await _apiHandler(requestUrl.pathSegments.last, data);
  } else {
    initTriggerHandler(beaverStore);
    response = await _triggerHandler(requestUrl, headers, data);
  }

  print('response: ${JSON.encode(response)}');
}

bool _isApiRequest(Uri requestUrl) =>
    requestUrl.pathSegments.length == 3 && requestUrl.pathSegments[1] == 'api';

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

Future _triggerHandler(Uri requestUrl, Map<String, String> headers,
    Map<String, Object> data) async {
  var result;
  try {
    final buildNumber = await triggerHandler(requestUrl, headers, data);
    result = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    print(e);
    result = {'status': 'failure', 'reason': e.toString()};
  }

  return result;
}
