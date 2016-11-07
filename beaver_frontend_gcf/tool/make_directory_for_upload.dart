import 'dart:async';
import 'dart:io';

import 'package:file_helper/file_helper.dart';

const uploadDirectory = 'upload';
const executableDartFile = 'beaver_ci.dart';
const executableDartSnapshotFile = '$executableDartFile.snapshot';

/// This tool should be run beaver_frontend_gcf directory.
Future<Null> main() async {
  await rm([uploadDirectory], directory: true, recursive: true);

  if (!await mkdir([uploadDirectory])) {
    print('Cannot create $uploadDirectory directory.');
    return;
  }

  final r = await Process.run('dart', [
    '--snapshot=$executableDartSnapshotFile',
    'bin/$executableDartFile'
  ]);
  if (r.exitCode != 0) {
    print('Cannot create $executableDartSnapshotFile.');
    print(r.stdout);
    print(r.stderr);
    return;
  }

  if (!await move([executableDartSnapshotFile], uploadDirectory)) {
    print('$executableDartSnapshotFile cannot be moved.');
    return;
  }

  if (!await copy([
    'third_party',
    'function/index.js',
  ], uploadDirectory)) {
    print('third_party or function/index.js cannot be copied.');
    return;
  }

  print('Done.');
}
