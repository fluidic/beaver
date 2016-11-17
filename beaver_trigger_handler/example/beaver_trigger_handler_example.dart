import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

Future<Null> main() async {
  final BeaverStore bs = await getBeaverStore(StorageServiceType.localMachine);
  final projectName = 'test';
  await bs.setNewProject(projectName);
  await bs.setConfig(projectName, new File('./beaver.yaml').readAsStringSync());

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
          ..write('Exception: $e.')
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
  final headers = new Map<String, String>();
  request.headers.forEach((name, value) {
    headers[name] = value.first;
  });

  final body = await request.transform(UTF8.decoder).join();
  final json = JSON.decode(body) as Map<String, Object>;

  var resp;
  try {
    final result = await triggerHandler(request.requestedUri, headers, json);
    resp = {'status': 'success'}..addAll(result);
  } catch (e) {
    resp = {'status': 'failure', 'reason': e.toString()};
  }

  return JSON.encode(resp);
}
