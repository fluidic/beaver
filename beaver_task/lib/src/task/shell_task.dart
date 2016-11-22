import 'dart:async';
import 'dart:io';

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

class ShellException extends TaskException {
  ShellException(String executable, int exitCode)
      : super('$executable exited with $exitCode');
}

@TaskClass('shell')
class ShellTask extends Task {
  final String executable;

  final List<String> arguments;

  ShellTask(this.executable, this.arguments);

  ShellTask.fromArgs(List<String> args)
      : this(args.first, args.getRange(1, args.length).toList());

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
      context.logger.shout(errorMessage);
    }
    if (result.exitCode != 0) {
      throw new ShellException(executable, result.exitCode);
    }
  }
}
