import 'package:args/command_runner.dart';

import './command/register_command.dart';
import './command/upload_command.dart';

getRunner() {
  final runner = new CommandRunner('beaver', 'CLI for beaver CI.');
  runner..addCommand(new RegisterCommand())..addCommand(new UploadCommand());
  return runner;
}
