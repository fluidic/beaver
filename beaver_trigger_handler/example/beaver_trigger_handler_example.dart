import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_config_store/beaver_config_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

main() async {
  final ConfigStore cs = new ConfigStore(StorageServiceType.localMachine);
  final projectId = await cs.setNewProject('test');
  await cs.setConfig(projectId, new File('./beaver.yaml').readAsStringSync());
  print(projectId);

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
  Map jsonData = JSON.decode(jsonString);

  final projectId = request.uri.pathSegments.last;

  final headers = {};
  request.headers.forEach((name, value) {
    headers[name] = value.first;
  });
  var status = 'success';
  try {
    final trigger = new Trigger('github', headers, jsonData);
    await triggerHandler(trigger, projectId);
  } catch (e) {
    status = 'failure';
  }
  return JSON.encode({'status': status});
}
