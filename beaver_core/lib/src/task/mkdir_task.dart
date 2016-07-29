import 'dart:async';
import 'dart:io';

import '../base.dart';

/// Creates a directory. Also non-existent parent directories are created,
/// when necessary. Does nothing if the directory already exist.
class MkdirTask extends Task {
  @override
  String get name => "mkdir";

  /// The directory to create.
  final String dir;

  MkdirTask(this.dir);

  @override
  Future<Directory> execute(Context context) async {
    final directory = new Directory(dir);
    await directory.create(recursive: true);
    return directory;
  }
}
