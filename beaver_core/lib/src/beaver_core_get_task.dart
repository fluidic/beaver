// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import './beaver_core_base.dart';

/// Get a file from a URL.
class GetTask extends Task {
  @override
  String get name => "get";

  /// The URL from which to retrieve a file.
  final String src;

  /// The file or directory where to store the retrieved file(s).
  final String dest;

  GetTask(this.src, this.dest);

  @override
  Future<File> execute(Context context) async {
    final srcUri = Uri.parse(src);
    final destFileName = _getSuggestedFilename(srcUri);

    final httpClient = new HttpClient();
    final request = await httpClient.getUrl(srcUri);
    final response = await request.close();
    final file = new File(destFileName);
    await response.pipe(file.openWrite());
    httpClient.close();

    return file;
  }

  String _getSuggestedFilename(Uri src) {
    // FIXME: Improve the method.
    // See https://chromium.googlesource.com/chromium/src/net/+/master/base/filename_util.h#32
    // FIXME: dest can be a file.
    return '${dest}/${src.pathSegments.last}';
  }
}
