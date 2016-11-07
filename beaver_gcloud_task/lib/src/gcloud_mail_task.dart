import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart';

import './gcloud_context_part.dart';

class GCloudMailException extends TaskException {
  GCloudMailException(String message) : super(message);
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

    // FIXME: hardcoded.
    final sendgridName = 'sendgridEmail';
    final sendgridKey = await _getSendgridKey(part);
    final url =
        'https://${part.region}-${part.project}.cloudfunctions.net/$sendgridName?sg_key=$sendgridKey';

    final httpClient = new HttpClient();
    final request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.write(JSON.encode({
      'to': to,
      // TODO: setUp(init)
      'from': 'notification@beaver-ci.org',
      'subject': subject,
      'body': content,
    }));
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();
    if (response.statusCode >= 400) {
      throw new GCloudMailException(responseBody);
    }
  }
}
