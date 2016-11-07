import 'dart:async';
import 'dart:io' show Platform;

import 'package:args/args.dart';
import 'package:beaver_task/beaver_task.dart';
import 'package:quiver_iterables/iterables.dart' show concat;

@TaskClass('install_dart_sdk')
class InstallDartSdkTask extends Task {
  final bool dev;

  final bool withDartium;

  final bool withContentShell;

  InstallDartSdkTask(
      {this.dev: false, this.withDartium: false, this.withContentShell: false});

  factory InstallDartSdkTask.fromArgs(List<String> args) {
    final parser = new ArgParser(allowTrailingOptions: true)
      ..addFlag('dev', defaultsTo: false, abbr: 'd')
      ..addFlag('withDartium', defaultsTo: false, abbr: 'D')
      ..addFlag('withContentShell', defaultsTo: false, abbr: 'C');
    final results = parser.parse(args);
    return new InstallDartSdkTask(
        dev: results['dev'],
        withDartium: results['withDartium'],
        withContentShell: results['withContentShell']);
  }

  @override
  Future<Null> execute(Context context) async {
    if (Platform.isMacOS) {
      List<String> installOptions = [];
      if (dev) {
        installOptions.add('--devel');
      }
      if (withDartium) {
        installOptions.add('--with-dartium');
      }
      if (withContentShell) {
        installOptions.add('--with-content-shell');
      }
      final tasks = [
        new ShellTask('brew', ['tap', 'dart-lang/dart']),
        new ShellTask(
            'brew',
            (concat([
              ['install', 'dart'],
              installOptions
            ]) as List<String>)
                .toList())
      ];
      await Future.forEach(tasks, (task) => task.execute(context));
    } else {
      // FIXME: Support Linux and Windows
      throw new UnsupportedPlatformException();
    }
  }
}
