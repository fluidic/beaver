import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_route/shelf_route.dart';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_task/beaver_task_runner.dart';

Future<shelf.Response> _handleRun(shelf.Request request) async {
  final body = await request.readAsString();

  Map<String, dynamic> params;
  try {
    params = JSON.decode(body) as Map<String, dynamic>;
  } on FormatException {
    return new shelf.Response(400);
  }

  final task = params['task'];
  final configJson = params['config'];
  if (task == null || configJson == null) {
    return new shelf.Response(400);
  }

  var config;
  try {
    config = new Config.fromJson(configJson);
  } catch (e) {
    return new shelf.Response(400);
  }
  final result = await runBeaver(task, config);
  final jsonResponse = JSON.encode(result);

  return new shelf.Response.ok(jsonResponse,
      headers: {'content-type': 'application/json'});
}

void main() {
  var myRouter = router()..post('/run', _handleRun);

  io.serve(myRouter.handler, InternetAddress.ANY_IP_V4, 8080).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}
