import 'dart:async';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';

/// Renames a file or directory.
@TaskClass('rename')
class RenameTask extends Task {
  /// The file or directory to be renamed.
  final String oldPath;

  /// The new name for the file or directory.
  final String newPath;

  RenameTask(this.oldPath, this.newPath);

  @override
  Future<Object> execute(Context context) =>
      file_helper.rename(oldPath, newPath);
}
