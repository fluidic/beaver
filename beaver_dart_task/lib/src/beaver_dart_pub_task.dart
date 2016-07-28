// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:beaver_core/beaver_core.dart';
import 'package:pub_wrapper/pub_wrapper.dart';

class PubTask extends Task {
  @override
  String get name => "pub";

  final List<String> args;
  final String processWorkingDir;

  PubTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  @override
  Future<Object> execute(Context context) async {
    final result = await runPub(args, processWorkingDir: processWorkingDir);
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
