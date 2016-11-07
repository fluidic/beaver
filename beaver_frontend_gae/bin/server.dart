import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

Future<Null> main() async {
  final beaverStore = await getBeaverStore(StorageServiceType.localMachine);
  initApiHandler(beaverStore);
  initTriggerHandler(beaverStore);
  final router = shelf_route.router()
    ..add('/api', ['POST'], _apiHandler, exactMatch: false)
    ..add('/', ['POST', 'GET'], _triggerHandler, exactMatch: false);
  var server =
      await shelf_io.serve(router.handler, InternetAddress.ANY_IP_V4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future _apiHandler(shelf.Request request) async {
  final api = request.url.pathSegments.last;
  final body = await request.readAsString();
  final json = body.isNotEmpty ? JSON.decode(body) : {};

  var result;
  try {
    final ret = await apiHandler(api, json as Map<String, Object>);
    result = {'status': 'success'}..addAll(ret);
  } catch (e) {
    print(e);
    result = {'statuc': 'failure', 'reason': e.toString()};
  }

  return new shelf.Response.ok(JSON.encode(result));
}

Future _triggerHandler(shelf.Request request) async {
  final body = await request.readAsString();
  Map<String, Object> json;
  if (body.isEmpty) {
    json = {};
  } else {
    json = JSON.decode(body) as Map<String, Object>;
  }

  var responseBody;
  try {
    final buildNumber =
        await triggerHandler(request.requestedUri, request.headers, json);
    responseBody = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    responseBody = {'status': 'failure', 'reason': e.toString()};
  }

  return new shelf.Response.ok(JSON.encode(responseBody));
}
