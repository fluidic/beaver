// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

/// Upload a file to Google Cloud Storage.
class GCloudStorageUploadTask extends Task {
  @override
  String get name => "gcloud_storage_upload";

  /// A file to upload.
  final String src;

  /// Google Cloud Storage bucket where to store the uploaded file.
  final String bucketName;

  GCloudStorageUploadTask(this.src, this.bucketName);

  @override
  Future<String> execute(Context context) async {
    throw new UnimplementedError();
  }
}
