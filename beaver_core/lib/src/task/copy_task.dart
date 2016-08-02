import 'dart:async';
import 'dart:io';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';

/// Copies files or directories into the directory.
/// If [dest] does not exist, it will be created.
@TaskClass('copy')
class CopyTask extends Task {
  /// The files or directories to be copied.
  final Iterable<String> src;

  /// The directory to be created.
  final String dest;

  CopyTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    final dir = new Directory(dest);
    if (!await dir.exists()) {
      if (!await file_helper.mkdir([dest], recursive: true)) {
        throw new TaskException('Directory \'${dest}\' creation is failed.');
      }
    }

    if (!await file_helper.copy(src, dest)) {
      throw new TaskException('Copy is failed.');
    }
  }
}
