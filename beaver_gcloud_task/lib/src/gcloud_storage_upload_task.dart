import 'dart:async';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart';
import 'package:path/path.dart' as path;

import './gcloud_context_part.dart';

class GCloudStorageUploadException extends TaskException {
  GCloudStorageUploadException(String message) : super(message);
}

/// Upload a file to Google Cloud Storage.
@TaskClass('gcloud_storage_upload')
class GCloudStorageUploadTask extends Task {
  /// A file to upload.
  final String src;

  /// Google Cloud Storage bucket where to store the uploaded file.
  final String bucketName;

  GCloudStorageUploadTask(this.src, this.bucketName);

  GCloudStorageUploadTask.fromArgs(List<String> args) : this(args[0], args[1]);

  /// Return a download link for the uploaded file.
  @override
  Future<Uri> execute(Context context) async {
    final file = new File(src);
    if (!await file.exists()) {
      throw new GCloudStorageUploadException(
          'Source file \'${src}\' does not exist.');
    }

    GCloudContextPart part = context.getPart('gcloud') as GCloudContextPart;
    if (part == null) {
      throw new GCloudStorageUploadException(
          'GCloudContextPart is not available.');
    }
    final storage = part.storage;

    var bucket;
    if (!await storage.bucketExists(bucketName)) {
      // FIXME: This line fails with the following error.
      //     DetailedApiRequestError(status: 403, message: The account for
      //     the specified project has been disabled.)
      bucket = await storage.createBucket(bucketName);
    } else {
      bucket = await storage.bucket(bucketName);
    }

    final objectName = _getSuggestedObjectName(src);
    await file.openRead().pipe(bucket.write(objectName));

    final objectInfo = await bucket.info(objectName);
    return objectInfo.downloadLink;
  }

  static String _getSuggestedObjectName(String filePath) =>
      path.basename(filePath);
}
