import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart';

import 'package:beaver_task/beaver_task_runner.dart';

Future<shelf.Response> _handleRun(shelf.Request request) async {
  final body = await request.readAsString();

  var params;
  try {
    params = JSON.decode(body);
  } on FormatException {
    return new shelf.Response(400);
  }

  final taskName = params['taskName'];
  // FIXME: Check if config is valid.
  final config = params['config'];
  if (taskName == null || config == null) {
    return new shelf.Response(400);
  }
  final taskArgs = params['taskArgs'] ?? [];

  final result = await runBeaver(taskName, taskArgs, config);
  final jsonResponse = JSON.encode(result);

  return new shelf.Response.ok(jsonResponse,
      headers: {'content-type': 'application/json'});
}

void main() {
  var myRouter = router()..post('/run', _handleRun);

  io.serve(myRouter.handler, 'localhost', 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

