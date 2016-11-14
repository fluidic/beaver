import 'dart:async';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:edit_distance/edit_distance.dart';

class BeaverCommandRunner extends CommandRunner {
  @override
  String get usageFooter =>
      'See https://github.com/fluidic/beaver/blob/master/doc/UserGuide.md '
      'for detailed documentation';

  BeaverCommandRunner(String executableName, String description)
      : super(executableName, description);

  @override
  Future run(Iterable<String> args) {
    ArgResults argResults = parse(args);

    if (argResults.command == null && argResults.rest.isNotEmpty) {
      final command = argResults.rest[0];
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
      return new Future.value();
    }

    return new Future.sync(() => runCommand(argResults));
  }
}
