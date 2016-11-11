import 'dart:async';

import 'package:args/args.dart';
import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:path/path.dart' as path;

@TaskClass('pub')
class PubTask extends Task {
  final List<String> args;
  final String processWorkingDir;
  final String pubPath;

  PubTask(this.args, {String processWorkingDir, String pubPath})
      : this.processWorkingDir = processWorkingDir,
        this.pubPath = pubPath;

  factory PubTask.fromArgs(List<String> args) {
    final parser = new ArgParser(allowTrailingOptions: true)
      ..addOption('process-working-dir', abbr: 'C')
      ..addOption('pub-path', abbr: 'p');
    final results = parser.parse(args);
    return new PubTask(results.rest,
        processWorkingDir: results['process-working-dir'],
        pubPath: results['pub-path']);
  }

  @override
  Future<Null> execute(Context context) async {
    var pubCommand = pub;
    if (pubPath != null) {
      pubCommand = new CommandWrapper(path.absolute(pubPath));
    }

    CommandResult result =
        await pubCommand.run(args, processWorkingDir: processWorkingDir);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
