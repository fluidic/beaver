import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:edit_distance/edit_distance.dart';

import './exit_codes.dart' as exit_codes;
import './io.dart';
import './version.dart';

class BeaverCommandRunner extends CommandRunner {
  @override
  String get usageFooter =>
      'See https://github.com/fluidic/beaver/blob/master/doc/UserGuide.md '
      'for detailed documentation';

  BeaverCommandRunner(String executableName, String description)
      : super(executableName, description) {
    argParser.addFlag('version',
        negatable: false, help: 'Print beaver version');
  }

  @override
  Future run(Iterable<String> args) async {
    ArgResults argResults = parse(args);

    if (argResults.command == null && argResults.rest.isNotEmpty) {
      _printCandidateCommands(argResults.rest[0]);
      return;
    }

    await runCommand(argResults);
  }

  @override
  Future runCommand(ArgResults options) async {
    if (options['version']) {
      print('$version');
      return;
    }
    await super.runCommand(options);

    // Explicitly exit on success to ensure that any dangling dart:io handles
    // don't cause the process to never terminate.
    await flushThenExit(exit_codes.success);
  }

  void _printCandidateCommands(String command) {
    print('$command is not a beaver cli_command. See \'beaver help\'.');

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
  }
}
