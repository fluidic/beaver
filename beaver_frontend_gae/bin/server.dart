import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

main() async {
  final beaverStore = await getBeaverStore(StorageServiceType.localMachine);
  initApiHandler(beaverStore);
  initTriggerHandler(beaverStore);
  final router = shelf_route.router()
    ..add('/api', ['POST'], _apiHandler, exactMatch: false)
    ..add('/github', ['POST'], _gitHubTriggerHandler, exactMatch: false);
  var server =
      await shelf_io.serve(router.handler, InternetAddress.ANY_IP_V4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future _apiHandler(shelf.Request request) async {
  final api = request.url.pathSegments.last;
  final requestBody =
      JSON.decode(await request.readAsString()) as Map<String, Object>;

  Map<String, Object> result;
  try {
    result = await apiHandler(api, requestBody);
  } catch (e) {
    print(e);
    return new shelf.Response.internalServerError();
  }

  final responseBody = {'status': 'success'};
  responseBody.addAll(result);
  return new shelf.Response.ok(JSON.encode(responseBody));
}

Future _gitHubTriggerHandler(shelf.Request request) async {
  final projectName = request.url.pathSegments.last;
  final requestBody =
      JSON.decode(await request.readAsString()) as Map<String, Object>;

  var responseBody;
  try {
    final trigger = new Trigger('github', request.headers, requestBody);
    final buildNumber = await triggerHandler(trigger, projectName);
    responseBody = {'status': 'success', 'build_number': buildNumber};
  } catch (e) {
    responseBody = {'status': 'failure', 'reason': e.toString()};
  }

  return new shelf.Response.ok(JSON.encode(responseBody));
}
