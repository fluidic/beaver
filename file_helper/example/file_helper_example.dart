// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file_helper/file_helper.dart' as file_helper;

Future<Null> main() async {
  // copy
  await new File('testFile').create();
  await file_helper.mkdir(['testDir']);
  await new File('testDir/nestedFile').create();
  await file_helper.mkdir(['testDir/nestedDir']);
  await new File('testDir/nestedDir/nestednestedFile').create();

  await file_helper.mkdir(['dest']);

  await file_helper.copy(['testFile', 'testDir'], 'dest');

  await file_helper
      .rm(['testFile', 'testDir', 'dest'], force: true, recursive: true);

  // move
  await new File('testFile').create();
  await file_helper.mkdir(['testDir']);
  await new File('testDir/nestedFile').create();
  await file_helper.mkdir(['testDir/nestedDir']);
  await new File('testDir/nestedDir/nestednestedFile').create();
  await file_helper.mkdir(['dest']);

  await file_helper.move(['testFile', 'testDir'], 'dest');

  await file_helper.rm(['dest'], force: true, recursive: true);

  // rename
  await new File('testFile').create();
  await file_helper.rename('testFile', 'renamedFile');
  await file_helper.rm(['renamedFile']);

  // touch
  await new File('testFile').create();
  await file_helper.touch(['testFile']);
  await file_helper.rm(['testFile']);
}
