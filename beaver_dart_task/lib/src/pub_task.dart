import 'dart:async';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_utils/beaver_utils.dart';
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
    final processWorkingDir = extractOption(args, '--process-working-dir');
    final pubPath = extractOption(args, '--pub-path');
    return new PubTask(args,
        processWorkingDir: processWorkingDir, pubPath: pubPath);
  }

  @override
  Future<Null> execute(Context context) async {
    var pubCommand;
    if (Platform.isLinux) {
      pubCommand = new CommandWrapper('/usr/lib/dart/bin/pub');
    } else {
      pubCommand = pub;
    }
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
