import 'dart:async';

import 'package:args/command_runner.dart';

class RmCommand extends Command {
  @override
  String get description => 'Remove a beaver CI env';

  @override
  String get name => 'rm';

  RmCommand() : super();

  @override
  Future<Null> run() async {
    return null;
  }
}
