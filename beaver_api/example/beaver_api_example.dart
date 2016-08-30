import 'dart:async';
import 'dart:convert';

import 'package:beaver_api/beaver_api.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

main() async {
  final router = shelf_route.router()
    ..add('/api', ['POST'], apiHandler, exactMatch: false);
  var server = await shelf_io.serve(router.handler, 'localhost', 8081);
  print('Serving at http://${server.address.host}:${server.port}');
}

// FIXME: Move this to beaver_api_base?
Future apiHandler(shelf.Request request) async {
  final api = request.url.pathSegments.last;
  final requestBody = JSON.decode(await request.readAsString());

  var responseBody = {'status': 'success'};
  try {
    switch (api) {
      case 'register':
        final projectName = requestBody['project'];
        final config = requestBody['config'];
        final id = await registerProject(projectName, config);
        responseBody['project'] = projectName;
        responseBody['id'] = id;
        break;
      case 'upload':
        // FIXME: Get file by a better way.
        final projectId = requestBody['id'];
        final config = requestBody['config'];
        await uploadConfigFile(projectId, config);
        break;
      case 'results':
        // FIXME: Implement.
        break;
      default:
        throw new Exception('Wrong API.');
    }
  } catch (e) {
    print(e);
    return new shelf.Response.internalServerError();
  }

  return new shelf.Response.ok(JSON.encode(responseBody));
}
