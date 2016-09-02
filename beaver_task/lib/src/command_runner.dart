import 'package:args/command_runner.dart';

import 'command/version.dart';

class BeaverCommandRunner extends CommandRunner {
  BeaverCommandRunner() : super('beaver', 'Continuous Integration System') {
    addCommand(new VersionCommand());
  }
}

