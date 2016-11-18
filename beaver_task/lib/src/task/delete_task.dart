import 'dart:async';

import 'package:beaver_utils/beaver_utils.dart';
import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

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

  factory DeleteTask.fromArgs(List<String> args) {
    final force = extractFlag(args, '--force', defaultsTo: true);
    final recursive = extractFlag(args, '--recursive', defaultsTo: true);
    return new DeleteTask(args, force: force, recursive: recursive);
  }

  @override
  Future<Object> execute(Context context) async {
    if (!await file_helper.rm(paths, force: force, recursive: recursive)) {
      throw new TaskException('Delete is failed.');
    }
  }
}
