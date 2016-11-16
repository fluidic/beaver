import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:path/path.dart' as path;

@TaskClass('dart')
class DartTask extends Task {
  final List<String> args;
  final String processWorkingDir;
  final String dartPath;

  DartTask(this.args, {String processWorkingDir, String dartPath})
      : this.processWorkingDir = processWorkingDir,
        this.dartPath = dartPath;

  factory DartTask.fromArgs(List<String> args) {
    final processWorkingDir = extractOption(args, '--process-working-dir');
    final dartPath = extractOption(args, '--dart-path');
    return new DartTask(args,
        processWorkingDir: processWorkingDir, dartPath: dartPath);
  }

  @override
  Future<Null> execute(Context context) async {
    var dartCommand = dart;
    if (dartPath != null) {
      dartCommand = new CommandWrapper(path.absolute(dartPath));
    }

    CommandResult result =
        await dartCommand.run(args, processWorkingDir: processWorkingDir);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
