import 'dart:async';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

/// Creates a directory. Also non-existent parent directories are created,
/// when necessary. Does nothing if the directory already exist.
@TaskClass('mkdir')
class MkdirTask extends Task {
  /// The directory will be created.
  final String dir;

  MkdirTask(this.dir);

  MkdirTask.fromArgs(List<String> args) : this(args[0]);

  @override
  Future<Object> execute(Context context) async {
    if (!await file_helper.mkdir([dir], recursive: true)) {
      throw new TaskException('Mkdir is failed.');
    }
  }
}
