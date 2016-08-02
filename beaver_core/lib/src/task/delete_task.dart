import 'dart:async';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';

/// Deletes files or directories.
@TaskClass('delete')
class DeleteTask extends Task {
  /// The files or directories to be deleted.
  final Iterable<String> paths;

  /// Whether to ignore nonexistent files.
  final bool force;

  /// Whether to remove the directories and their contents recursively.
  final bool recursive;

  DeleteTask(this.paths, {force: true, recursive: true})
      : force = force,
        recursive = recursive;

  @override
  Future<Object> execute(Context context) =>
      file_helper.rm(paths, force: force, recursive: recursive);
}
