// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:quiver_iterables/iterables.dart' show concat;

import './beaver_core_base.dart';
import './beaver_core_exception.dart';
import './beaver_core_shell_task.dart';

class InstallDartSDKTask extends Task {
  @override
  String get name => 'install_dart_sdk';

  final bool dev;

  final bool withDartium;

  final bool withContentShell;

  InstallDartSDKTask(
      {this.dev: false, this.withDartium: false, this.withContentShell: false});

  @override
  Future<Object> execute(Context context) async {
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
      return Future.forEach(tasks, (task) => task.execute(context));
    } else {
      // FIXME: Support Linux and Windows
      throw new UnsupportedPlatformException();
    }
  }
}
