import 'dart:async';

import 'package:git/git.dart';

import '../annotation.dart';
import '../base.dart';
import '../task.dart';

@TaskClass('git')
class GitTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  GitTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  GitTask.fromArgs(List<String> args) : this(args);

  @override
  Future<Null> execute(Context context) async {
    final result = await runGit(args, processWorkingDir: processWorkingDir);
    final infoMessage = result.stdout.toString();
    if (infoMessage.isNotEmpty) {
      context.logger.info(infoMessage);
    }
    final errorMessage = result.stderr.toString();
    if (errorMessage.isNotEmpty) {
      context.logger.shout(errorMessage);
    }
  }
}
