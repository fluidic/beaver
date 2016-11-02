import 'package:args/command_runner.dart';

import './beaver_command_runner.dart';
import './cli_command/create.dart';
import './cli_command/delete.dart';
import './cli_command/describe.dart';
import './cli_command/get_results.dart';
import './cli_command/list.dart';
import './cli_command/setup.dart';
import './cli_command/test.dart';
import './cli_command/upload.dart';

CommandRunner getRunner() {
  final runner = new BeaverCommandRunner('beaver', 'CLI for beaver CI.');
  runner
    ..addCommand(new CreateCommand())
    ..addCommand(new DeleteCommand())
    ..addCommand(new DescribeCommand())
    ..addCommand(new GetResultsCommand())
    ..addCommand(new ListCommand())
    ..addCommand(new SetupCommand())
    ..addCommand(new TestCommand())
    ..addCommand(new UploadCommand());

  return runner;
}
