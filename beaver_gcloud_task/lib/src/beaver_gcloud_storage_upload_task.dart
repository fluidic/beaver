import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart';
import 'package:path/path.dart' as path;

import './beaver_gcloud_context_part.dart';

class GCloudStorageUploadException extends TaskException {
  final _message;

  GCloudStorageUploadException(this._message);

  @override
  String toString() => _message;
}

/// Upload a file to Google Cloud Storage.
class GCloudStorageUploadTask extends Task {
  @override
  String get name => "gcloud_storage_upload";

  /// A file to upload.
  final String src;

  /// Google Cloud Storage bucket where to store the uploaded file.
  final String bucketName;

  GCloudStorageUploadTask(this.src, this.bucketName);

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

