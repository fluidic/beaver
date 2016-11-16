import 'dart:async';

import 'package:beaver_utils/beaver_utils.dart';
import 'package:file_helper/file_helper.dart' as file_helper;

import '../annotation.dart';
import '../base.dart';
import '../task.dart';

/// Touches files or directories.
@TaskClass('touch')
class TouchTask extends Task {
  /// The files or directories to be touched.
  final Iterable<String> paths;

  /// Whether to create nonexistent path.
  final bool create;

  TouchTask(this.paths, {create: true}) : create = create;

  factory TouchTask.fromArgs(List<String> args) {
    final create = extractFlag(args, '--create', defaultsTo: true);
    return new TouchTask(args, create: create);
  }

  @override
  Future<Object> execute(Context context) async {
    if (!await file_helper.touch(paths, create: create)) {
      throw new TaskException('Touch is failed.');
    }
  }
}
