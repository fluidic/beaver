import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:beaver_store/beaver_store.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

main() async {
  initApiHandler(await getBeaverStore(StorageServiceType.localMachine));
  final router = shelf_route.router()
    ..add('/api', ['POST'], handler, exactMatch: false);
  var server = await shelf_io.serve(router.handler, 'localhost', 8081);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future handler(shelf.Request request) async {
  final api = request.url.pathSegments.last;
  final requestBody = JSON.decode(await request.readAsString());

  var result;
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
