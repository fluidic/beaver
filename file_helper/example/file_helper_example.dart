// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:file_helper/file_helper.dart';

main() async {
  // copy
  await new File('testFile').create();
  await FileHelper.mkdir(['testDir']);
  await new File('testDir/nestedFile').create();
  await FileHelper.mkdir(['testDir/nestedDir']);
  await new File('testDir/nestedDir/nestednestedFile').create();

  await FileHelper.mkdir(['dest']);

  await FileHelper.copy(['testFile', 'testDir'], 'dest');

  await FileHelper
      .rm(['testFile', 'testDir', 'dest'], force: true, recursive: true);

  // move
  await new File('testFile').create();
  await FileHelper.mkdir(['testDir']);
  await new File('testDir/nestedFile').create();
  await FileHelper.mkdir(['testDir/nestedDir']);
  await new File('testDir/nestedDir/nestednestedFile').create();
  await FileHelper.mkdir(['dest']);

  await FileHelper.move(['testFile', 'testDir'], 'dest');

  await FileHelper.rm(['dest'], force: true, recursive: true);

  // rename
  await new File('testFile').create();
  await FileHelper.rename('testFile', 'renamedFile');
  await FileHelper.rm(['renamedFile']);

  // touch
  await new File('testFile').create();
  await FileHelper.touch(['testFile']);
  await FileHelper.rm(['testFile']);
}
