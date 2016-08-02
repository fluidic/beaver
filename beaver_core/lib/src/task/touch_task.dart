import 'dart:async';

import 'package:file_helper/file_helper.dart';

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

  @override
  Future<Object> execute(Context context) =>
      FileHelper.touch(paths, create: create);
}
