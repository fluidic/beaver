// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

/// Untar a Tar file.
class UntarTask extends Task {
  @override
  String get name => "untar";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UntarTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}
