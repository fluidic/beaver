import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:edit_distance/edit_distance.dart';

import './cli_command/create.dart';
import './cli_command/delete.dart';
import './cli_command/describe.dart';
import './cli_command/get_results.dart';
import './cli_command/list.dart';
import './cli_command/setup.dart';
import './cli_command/test.dart';
import './cli_command/upload.dart';

class BeaverCommandRunner extends CommandRunner {
  BeaverCommandRunner(String executableName, String description)
      : super(executableName, description);

  @override
  Future run(Iterable<String> args) {
    ArgResults argResults = parse(args);

    if (argResults.command == null && argResults.rest.isNotEmpty) {
      final command = argResults.rest[0];
      print('${command} is not a beaver cli_command. See \'beaver help\'.');

      StringDistance d = new Levenshtein();
      final candidates =
          commands.keys.where((key) => d.distance(command, key) <= 2);
      if (candidates.isNotEmpty) {
        if (candidates.length == 1) {
          print('\nDid you mean this?');
        } else {
          print('\nDid you mean one of these?');
        }
        for (final candidate in candidates) {
          print('\t$candidate');
        }
      }
      return new Future.value();
    }

    return new Future.sync(() => runCommand(argResults));
  }
}

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
