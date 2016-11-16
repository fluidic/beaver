import 'dart:async';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';

@TaskClass('install_docker')
class InstallDockerTask extends Task {
  InstallDockerTask();

  InstallDockerTask.fromArgs(List<String> args);

  @override
  Future<Null> execute(Context context) async {
    if (Platform.isLinux && await _isDebian()) {
      // FIXME: To use sudo.
      final bash = new CommandWrapper('bash');
      await _runCommand(context, bash, ['-c', 'sudo apt-get update']);
      await _runCommand(
          context, bash, ['-c', 'sudo apt-get install -y docker.io']);
    } else {
      // FIXME: Support the other Linux, Windows and Mac.
      throw new UnimplementedError();
    }
  }

  Future<bool> _isDebian() async {
    // FIXME: When using uname directly, it returns nothing.
    final bash = new CommandWrapper('bash');

    final result = await bash.run(['-c', 'uname -a']);
    if (result.stdout.join(' ').contains('Debian')) {
      return true;
    }
    return false;
  }

  Future<Null> _runCommand(
      Context context, CommandWrapper command, List<String> args) async {
    final result = await command.run(args);
    for (final line in result.stdout) {
      context.logger.info(line);
    }
    for (final line in result.stderr) {
      context.logger.shout(line);
    }
  }
}
