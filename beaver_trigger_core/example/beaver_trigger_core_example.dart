import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_trigger_core/beaver_trigger_core.dart';

main() async {
  final context = new HttpTriggerContext(
      Uri.parse('http://localhost:8080'), new TriggerConfigMemoryStore());
  final trigger = new HttpTrigger(context);

  final server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  await for (final req in server) {
    ContentType contentType = req.headers.contentType;

    if (req.method == 'POST' &&
        contentType != null &&
        contentType.mimeType == 'application/json') {
      try {
        final jsonString = await req.transform(UTF8.decoder).join();
        Map jsonData = JSON.decode(jsonString);

        final json = await trigger.handle(req, jsonData);
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

class HttpTriggerContext extends Context {
  HttpTriggerContext(Uri url, TriggerConfigStore triggerConfigStore)
      : super(url, triggerConfigStore);
}

class HttpTrigger {
  final Context context;

  HttpTrigger(this.context);

  Future handle(HttpRequest request, Map<String, String> jsonData) async {
    final endpoint = await setTriggerConfig(
        context,
        sourceTypeFromString(jsonData['sourceType']),
        Uri.parse(jsonData['sourceUrl']),
        triggerTypeFromString(jsonData['triggerType']));

    print(await getTriggerConfig(context, endpoint));

    return JSON.encode({'hello': 'world'});
  }
}
