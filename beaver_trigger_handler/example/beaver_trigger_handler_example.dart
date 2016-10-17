import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

main() async {
  final BeaverStore bs = await getBeaverStore(StorageServiceType.localMachine);
  final projectId = await bs.setNewProject('test');
  await bs.setConfig(projectId, new File('./beaver.yaml').readAsStringSync());
  print(projectId);

  initTriggerHandler(bs);

  final server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  await for (final req in server) {
    ContentType contentType = req.headers.contentType;

    if (req.method == 'POST' &&
        contentType != null &&
        contentType.mimeType == 'application/json') {
      try {
        final json = await handler(req);
        req.response
          ..statusCode = HttpStatus.OK
          ..write(JSON.encode(json))
          ..close();
      } catch (e) {
        req.response
          ..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
          ..write('Exception: ${e}.')
          ..close();
      }
    } else {
      req.response
        ..statusCode = HttpStatus.METHOD_NOT_ALLOWED
        ..write('Unsupported request: ${req.method}.')
        ..close();
    }
  }
}

Future<String> handler(HttpRequest request) async {
  final jsonString = await request.transform(UTF8.decoder).join();
  final jsonData = JSON.decode(jsonString) as Map<String, Object>;

  final projectId = request.uri.pathSegments.last;

  final headers = new Map<String, String>();
  request.headers.forEach((name, value) {
    headers[name] = value.first;
  });

  var resp;
  try {
    final trigger = new Trigger('github', headers, jsonData);
    final buildNumber = await triggerHandler(trigger, projectId);
    resp = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    resp = {'status': 'failure', 'reason': e.toString()};
  }

  return JSON.encode(resp);
}
