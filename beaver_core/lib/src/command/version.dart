import 'package:args/command_runner.dart';

/// Handles the `version` beaver command.
class VersionCommand extends Command {
  String get name => 'version';
  String get description => 'Print beaver version.';
  String get invocation => 'beaver version';

  void run() {
    print('Beaver 0.1.0');
  }
}

