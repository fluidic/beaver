import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:beaver_task/beaver_task.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../annotation.dart';
import '../base.dart';

/// Create a temporary file.
@TaskClass('tempfile')
class TempfileTask extends Task {
  final String prefix;
  final String suffix;

  TempfileTask({String prefix, String suffix})
      : this.prefix = prefix,
        this.suffix = suffix;

  factory TempfileTask.fromArgs(List<String> args) {
    final parser = new ArgParser()
      ..addOption('prefix', defaultsTo: '')
      ..addOption('suffix', defaultsTo: '');
    final results = parser.parse(args);
    return new TempfileTask(
        prefix: results['prefix'], suffix: results['suffix']);
  }

  @override
  Future<File> execute(Context context) {
    final tempFilename = '$prefix${new Uuid().v4()}$suffix';
    return new File(path.join(Directory.systemTemp.path, tempFilename))
        .create();
  }
}
