import 'dart:io';

import 'package:file_helper/file_helper.dart';

const uploadDirectory = 'upload';
const executableDartFile = 'beaver_ci.dart';
const executableDartSnapshotFile = '${executableDartFile}.snapshot';

/// This tool should be run beaver_frontend_gcf directory.
main() async {
  mkdir([uploadDirectory]);

  await Process.run('dart', [
    '--snapshot=${executableDartFile}.snapshot',
    'bin/${executableDartFile}'
  ]);

  move([executableDartSnapshotFile], uploadDirectory);

  copy([
    'third_party',
    'function/index.js',
  ], uploadDirectory);
}
