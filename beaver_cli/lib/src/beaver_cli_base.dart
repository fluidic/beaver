import 'package:args/command_runner.dart';

import './command/register_command.dart';
import './command/result_command.dart';
import './command/test_command.dart';
import './command/upload_command.dart';

CommandRunner getRunner() {
  final runner = new CommandRunner('beaver', 'CLI for beaver CI.');
  runner
    ..addCommand(new RegisterCommand())
    ..addCommand(new UploadCommand())
    ..addCommand(new TestCommand())
    ..addCommand(new ResultCommand());
  return runner;
}
