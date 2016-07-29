import 'dart:async';

import 'package:beaver_core/beaver_core.dart';
import 'package:pub_wrapper/pub_wrapper.dart';

@TaskClass('pub')
class PubTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  PubTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  @override
  Future<Null> execute(Context context) async {
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
