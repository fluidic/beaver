import 'dart:async';

import 'package:file_helper/file_helper.dart';

import '../annotation.dart';
import '../base.dart';

/// Creates a directory. Also non-existent parent directories are created,
/// when necessary. Does nothing if the directory already exist.
@TaskClass('mkdir')
class MkdirTask extends Task {
  /// The directory will be created.
  final String dir;

  MkdirTask(this.dir);

  @override
  Future<Object> execute(Context context) =>
      FileHelper.mkdir([dir], recursive: true);
}
