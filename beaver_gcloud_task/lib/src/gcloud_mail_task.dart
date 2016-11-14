import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart';

import './gcloud_context_part.dart';

class GCloudMailException extends TaskException {
  GCloudMailException(String message) : super(message);
}

Future<HttpClientResponse> _sendgridEmail(String apiKey, String to, String from,
    String subject, String content) async {
  final requestBody = JSON.encode({
    "personalizations": [
      {
        "to": [
          {"email": to}
        ]
      }
    ],
    "from": {"email": from},
    "subject": subject,
    "content": [
      {"type": "text/plain", "value": content}
    ]
  });
  final client = new HttpClient();
  final response = ((await client
          .postUrl(Uri.parse('https://api.sendgrid.com/v3/mail/send')))
        ..headers.contentType =
            new ContentType('application', 'json', charset: 'utf-8')
        ..headers.set(HttpHeaders.AUTHORIZATION, 'Bearer $apiKey')
        ..write(requestBody))
      .close();
  client.close();
  return response;
}

@TaskClass('gcloud_mail')
class GCloudMailTask extends Task {
  final String to;
  final String subject;
  final String content;

  GCloudMailTask(this.to, this.subject, this.content);

  GCloudMailTask.fromArgs(List<String> args) : this(args[0], args[1], args[2]);

  Future<String> _getSendgridKey(GCloudContextPart part) async {
    // FIXME: Currently, the bucket and the object must be set manually.
    final bucketName = 'staging1';
    final objectName = 'sgKey.txt';
    final buffer = await part.storage
        .bucket(bucketName)
        .read(objectName)
        .fold(new StringBuffer(), (S, bytes) => S..write(UTF8.decode(bytes)));
    return buffer.toString().trim();
  }

  @override
  Future<Null> execute(Context context) async {
    final part = context.getPart('gcloud') as GCloudContextPart;
    if (part == null) {
      throw new GCloudMailException('GCloudContextPart is not avaliable.');
    }

    final sendgridKey = await _getSendgridKey(part);
    final response = await _sendgridEmail(
        sendgridKey, to, 'notification@beaver-ci.org', subject, content);
    final responseBody = await response.transform(UTF8.decoder).join();
    if (response.statusCode >= 400) {
      throw new GCloudMailException(responseBody);
    }
  }
}
