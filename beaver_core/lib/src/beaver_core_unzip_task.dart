// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

/// Unzip a zip file.
class UnzipTask extends Task {
  @override
  String get name => "unzip";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UnzipTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

