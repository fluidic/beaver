import 'dart:async';
import 'dart:io' show Platform;

import 'package:beaver_task/beaver_task.dart';
import 'package:quiver_iterables/iterables.dart' show concat;

@TaskClass('install_dart_sdk')
class InstallDartSdkTask extends Task {
  final bool dev;

  final bool withDartium;

  final bool withContentShell;

  InstallDartSdkTask(
      {this.dev: false, this.withDartium: false, this.withContentShell: false});

  @override
  Future<Null> execute(Context context) async {
    if (Platform.isMacOS) {
      final installOptions = [];
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
            concat([
              ['install', 'dart'],
              installOptions
            ]).toList())
      ];
      await Future.forEach(tasks, (task) => task.execute(context));
    } else {
      // FIXME: Support Linux and Windows
      throw new UnsupportedPlatformException();
    }
  }
}
