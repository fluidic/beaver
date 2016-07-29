import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import './beaver_core_base.dart';

/// Download a file from a URL.
class DownloadTask extends Task {
  @override
  String get name => 'download';

  /// The URL from which to retrieve a file.
  final String src;

  /// The file or directory where to store the retrieved file(s).
  final String dest;

  DownloadTask(this.src, this.dest);

  @override
  Future<File> execute(Context context) async {
    final srcUri = Uri.parse(src);
    final destFilename = _getSuggestedFilename(srcUri);

    final httpClient = new HttpClient();
    final request = await httpClient.getUrl(srcUri);
    final response = await request.close();
    final file = new File(destFilename);
    await response.pipe(file.openWrite());
    httpClient.close();

    return file;
  }

  String _getSuggestedFilename(Uri src) {
    // FIXME: Improve the method.
    // See https://chromium.googlesource.com/chromium/src/net/+/master/base/filename_util.h#32
    // FIXME: dest can be a file.
    return path.join(dest, src.pathSegments.last);
  }
}
