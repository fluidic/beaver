import 'dart:async';

import 'package:beaver_utils/beaver_utils.dart';
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

  factory GitTask.fromArgs(List<String> args) {
    final processWorkingDir = extractOption(args, '--process-working-dir');
    return new GitTask(args, processWorkingDir: processWorkingDir);
  }

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
