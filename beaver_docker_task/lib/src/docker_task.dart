import 'dart:async';

import 'package:args/args.dart';
import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';

final docker = new CommandWrapper('docker');

@TaskClass('docker')
class DockerTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  DockerTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  factory DockerTask.fromArgs(List<String> args) {
    final parser = new ArgParser(allowTrailingOptions: true)
      ..addOption('process-working-dir', abbr: 'C');
    final results = parser.parse(args);
    return new DockerTask(results.rest,
        processWorkingDir: results['process-working-dir']);
  }

  @override
  Future<Null> execute(Context context) async {
    final result = await docker.run(args, processWorkingDir: processWorkingDir);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
