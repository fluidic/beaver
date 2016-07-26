// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

/// Get a file from a URL.
class GetTask extends Task {
  @override
  String get name => "get";

  /// The URL from which to retrieve a file.
  final String src;

  /// The file or directory where to store the retrieved file(s).
  final String dest;

  GetTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

