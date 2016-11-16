import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';

@TaskClass('docker')
class DockerTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  DockerTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  factory DockerTask.fromArgs(List<String> args) {
    final processWorkingDir = extractOption(args, '--process-working-dir');
    return new DockerTask(args, processWorkingDir: processWorkingDir);
  }

  @override
  Future<Null> execute(Context context) async {
    final bash = new CommandWrapper('bash');
    final result = await bash.run(['-c', 'docker ' + args.join(' ')],
        processWorkingDir: processWorkingDir);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
