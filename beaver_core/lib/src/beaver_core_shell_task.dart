// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import './beaver_core_base.dart';

class ShellException extends TaskException {
  final String _executable;

  final int _exitCode;

  ShellException(this._executable, this._exitCode);

  @override
  String toString() => '${_executable} exited with ${_exitCode}';
}

class ShellTask extends Task {
  @override
  String get name => "shell";

  final String executable;

  final List<String> arguments;

  ShellTask(this.executable, this.arguments);

  @override
  Future<Object> execute(Context context) async {
    // FIXME: Process.run may throw a ProcessException if executable does not exist.
    final result = await Process.run(executable, arguments);
    final infoMessage = result.stdout.toString();
    if (infoMessage.isNotEmpty) {
      context.logger.info(infoMessage);
    }
    final errorMessage = result.stderr.toString();
    if (errorMessage.isNotEmpty) {
      context.logger.error(errorMessage);
    }
    if (result.exitCode != 0) {
      throw new ShellException(executable, result.exitCode);
    }
  }
}
