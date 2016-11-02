import 'package:args/command_runner.dart';

import './admin_cli_command/create.dart';
import './admin_cli_command/rm.dart';
import './beaver_command_runner.dart';

CommandRunner getRunner() {
  final runner =
      new BeaverCommandRunner('beaver_admin', 'Admin CLI for beaver CI.');
  runner..addCommand(new CreateCommand())..addCommand(new RmCommand());
  return runner;
}
