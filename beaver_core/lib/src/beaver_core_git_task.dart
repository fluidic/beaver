// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:git/git.dart';

import './beaver_core_base.dart';

class GitTask extends Task {
  @override
  String get name => "git";

  final List<String> args;

  GitTask(this.args);

  @override
  Future<Object> execute(Context context) async {
    final result = await runGit(args);
    final infoMessage = result.stdout.toString();
    if (infoMessage.isNotEmpty) {
      context.logger.info(infoMessage);
    }
    final errorMessage = result.stderr.toString();
    if (errorMessage.isNotEmpty) {
      context.logger.error(errorMessage);
    }
  }
}
