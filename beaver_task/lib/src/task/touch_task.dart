import 'dart:async';

import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';

/// Touches files or directories.
@TaskClass('touch')
class TouchTask extends Task {
  /// The files or directories to be touched.
  final Iterable<String> paths;

  /// Whether to create nonexistent path.
  final bool create;

  TouchTask(this.paths, {create: true}) : create = create;

  TouchTask.fromArgs(List<String> args) : this(args);

  @override
  Future<Object> execute(Context context) async {
    if (!await file_helper.touch(paths, create: create)) {
      throw new TaskException('Touch is failed.');
    }
  }
}
