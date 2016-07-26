// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:quiver_collection/collection.dart';

class TaskError extends Error {}

abstract class Context {
  Configuration get configuration;
  Logger get logger;
}

enum LogLevel { INFO, WARN, ERROR }

// FIXME: Add more methods from https://www.dartdocs.org/documentation/logging
abstract class Logger {
  void log(LogLevel level, message);

  void info(message) => log(LogLevel.INFO, message);
  void warn(message) => log(LogLevel.WARN, message);
  void error(message) => log(LogLevel.ERROR, message);
}

class Configuration extends DelegatingMap<String, Object> {
  /// Get a string (linux, macos, windows, android, or ios) representing the operating system.
  String get operatingSystem => Platform.operatingSystem;

  bool get isLinux => Platform.isLinux;

  bool get isMacOS => Platform.isMacOS;

  bool get isWindows => Platform.isWindows;

  String get pathSeparator => Platform.pathSeparator;

  String get localHostname => Platform.localHostname;

  int get numberOfProcessors => Platform.numberOfProcessors;

  final Map<String, Object> _map;

  Map<String, Object> get delegate => _map;

  Configuration({Map<String, Object> map: const {}}) : _map = map;
}

abstract class Task {
  String get name;

  const Task();

  Future<Object> execute(Context context);
}
