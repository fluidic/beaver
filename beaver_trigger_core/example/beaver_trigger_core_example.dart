import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_trigger_core/beaver_trigger_core.dart';

main() async {
  final server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  await for (final req in server) {
    ContentType contentType = req.headers.contentType;

    if (req.method == 'POST' &&
        contentType != null &&
        contentType.mimeType == 'application/json') {
      try {
        final json = await handle(req);
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

final context = new Context(
    Uri.parse('http://localhost:8080'), new TriggerConfigMemoryStore());

Future<String> handle(HttpRequest request) async {
  final jsonString = await request.transform(UTF8.decoder).join();
  Map jsonData = JSON.decode(jsonString);

  var trigger;
  if (isSpecialTrigger(request.uri)) {
    trigger = new SpecialTrigger(context, jsonData);
  } else {
    trigger = new JobTrigger(context, jsonData, request: request);
  }

  final result = await trigger.trigger();

  return JSON.encode(result);
}
