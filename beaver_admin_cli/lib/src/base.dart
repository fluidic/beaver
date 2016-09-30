import 'package:args/command_runner.dart';

import './command/create.dart';
import './command/rm.dart';

CommandRunner getRunner() {
  final runner = new CommandRunner('beaver_admin', 'Admin CLI for beaver CI.');
  runner..addCommand(new CreateCommand())..addCommand(new RmCommand());
  return runner;
}
