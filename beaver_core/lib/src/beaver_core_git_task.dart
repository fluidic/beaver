import 'dart:async';

import 'package:git/git.dart';

import './beaver_core_base.dart';

class GitTask extends Task {
  @override
  String get name => "git";

  final List<String> args;
  final String processWorkingDir;

  GitTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  @override
  Future<Null> execute(Context context) async {
    final result = await runGit(args, processWorkingDir: processWorkingDir);
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
