import 'dart:async';
import 'dart:io';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';

/// Moves files or directories into the directory.
/// If [dest] does not exist, it will be created.
@TaskClass('move')
class MoveTask extends Task {
  /// The files or directories to be moved.
  final Iterable<String> src;

  /// The directory to be created.
  final String dest;

  MoveTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    final dir = new Directory(dest);
    if (!await dir.exists()) {
      await file_helper.mkdir([dest], recursive: true);
    }

    await file_helper.move(src, dest);
  }
}
