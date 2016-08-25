import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

main() async {
  final server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  await for (final req in server) {
    ContentType contentType = req.headers.contentType;

    if (req.method == 'POST' &&
        contentType != null &&
        contentType.mimeType == 'application/json') {
      try {
        final json = await _handle(req);
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

Future<String> _handle(HttpRequest request) async {
  final jsonString = await request.transform(UTF8.decoder).join();
  Map jsonData = JSON.decode(jsonString);

  final triggerId = request.uri.pathSegments.last;
  if (triggerId == 'setTrigger') {
    final id = await setTrigger(jsonData);
    return JSON.encode({'id': id});
  }

  var status = 'success';
  try {
    await trigger_handler(triggerId, jsonData, request: request);
  } catch (e) {
    status = 'failure';
  }
  return JSON.encode({'status': status});
}
