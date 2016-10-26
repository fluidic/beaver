import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../annotation.dart';
import '../base.dart';
import '../task.dart';

class PostTaskResult {
  final int statusCode;

  // JSON will be used for this.
  final Object body;

  PostTaskResult(this.statusCode, this.body);
}

/// Post data to the URL.
@TaskClass('post')
class PostTask extends Task {
  /// The URL that is requested.
  final String url;

  /// The data to send. JSON will be used.
  final Object data;

  PostTask(this.url, this.data);

  PostTask.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<PostTaskResult> execute(Context context) async {
    final httpClient = new HttpClient();

    final request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.write(JSON.encode(data));
    final response = await request.close();

    final body = await response.transform(UTF8.decoder).join();
    httpClient.close();

    return new PostTaskResult(
        response.statusCode, body.isNotEmpty ? JSON.decode(body) : null);
  }
}
