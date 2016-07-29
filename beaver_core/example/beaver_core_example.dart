// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:beaver_core/beaver_core.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';

main() => runBeaver([
      new InstallDartSdkTask(withContentShell: true, withDartium: true),
      new GitTask(['clone', 'git@github.com:fluidic/symbol.git']),
      new PubTask(['get'], processWorkingDir: 'symbol'),
      new PubTask(['run', 'test'], processWorkingDir: 'symbol')
    ]);
