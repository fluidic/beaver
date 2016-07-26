// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

class ShellTask extends Task {
  @override
  String get name => "shell";

  final String executable;

  final List<String> arguments;

  ShellTask(this.executable, this.arguments);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

