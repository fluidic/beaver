import 'dart:async';
import 'dart:io';

import './annotation.dart';
import './base.dart';

class ShellException extends TaskException {
  final String _executable;

  final int _exitCode;

  ShellException(this._executable, this._exitCode);

  @override
  String toString() => '${_executable} exited with ${_exitCode}';
}

@TaskClass('shell')
class ShellTask extends Task {
  final String executable;

  final List<String> arguments;

  ShellTask(this.executable, this.arguments);

  @override
  Future<Null> execute(Context context) async {
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
