import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';

final docker = new CommandWrapper('docker');

@TaskClass('docker')
class DockerTask extends Task {
  final List<String> args;

  DockerTask(this.args);
  DockerTask.fromArgs(List<String> args) : args = args;

  @override
  Future<Null> execute(Context context) async {
    final result = await docker.run(args);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
