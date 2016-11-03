import 'dart:async';

import 'package:args/args.dart';
import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';

@TaskClass('pub')
class PubTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  PubTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  factory PubTask.fromArgs(List<String> args) {
    final parser = new ArgParser()..addOption('process-working-dir', abbr: 'C');
    final results = parser.parse(args);
    return new PubTask(results.rest,
        processWorkingDir: results['process-working-dir']);
  }

  @override
  Future<Null> execute(Context context) async {
    CommandResult result =
        await pub.run(args, processWorkingDir: processWorkingDir);
    for (final line in result.stderr) {
      context.logger.info(line);
    }
    for (final line in result.stdout) {
      context.logger.shout(line);
    }
  }
}
