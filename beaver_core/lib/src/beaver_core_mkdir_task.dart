// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

/// Creates a directory. Also non-existent parent directories are created,
/// when necessary. Does nothing if the directory already exist.
class MkdirTask extends Task {
  @override
  String get name => "mkdir";

  /// The directory to create.
  final String dir;

  MkdirTask(this.dir);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

