import 'dart:async';

import 'package:args/command_runner.dart';

class CreateCommand extends Command {
  @override
  String get description => 'Create a beaver CI env';

  @override
  String get name => 'create';

  CreateCommand() : super();

  @override
  Future<Null> run() async {
    return null;
  }
}
