import 'package:args/command_runner.dart';

import './command/register.dart';
import './command/result.dart';
import './command/test.dart';
import './command/upload.dart';

CommandRunner getRunner() {
  final runner = new CommandRunner('beaver', 'CLI for beaver CI.');
  runner
    ..addCommand(new RegisterCommand())
    ..addCommand(new UploadCommand())
    ..addCommand(new TestCommand())
    ..addCommand(new ResultCommand());
  return runner;
}
