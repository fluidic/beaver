import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../annotation.dart';
import '../base.dart';

/// Create a temporary file.
@TaskClass('tempfile')
class TempfileTask extends Task {
  final String suffix;

  TempfileTask(this.suffix);

  TempfileTask.fromArgs(List<String> args) : this(args.length == 0 ? null : args[0]);

  @override
  Future<File> execute(Context context) async {
    final tempDir = Directory.systemTemp.path;
    final tempFilename = '${new Uuid().v4()}${suffix ?? ''}';
    return new File(path.join(tempDir, tempFilename)).create();
  }
}
