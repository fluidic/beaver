import 'dart:async';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

/// Renames a file or directory.
@TaskClass('rename')
class RenameTask extends Task {
  /// The file or directory to be renamed.
  final String oldPath;

  /// The new name for the file or directory.
  final String newPath;

  RenameTask(this.oldPath, this.newPath);

  RenameTask.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<Object> execute(Context context) async {
    if (!await file_helper.rename(oldPath, newPath)) {
      throw new TaskException('Rename is failed.');
    }
  }
}
