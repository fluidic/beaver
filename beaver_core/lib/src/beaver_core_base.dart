// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:quiver_collection/collection.dart';

class TaskException implements Exception {}

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
  final Map<String, Object> _map;

  Map<String, Object> get delegate => _map;

  Configuration({Map<String, Object> map: const {}}) : _map = map;
}

abstract class Task {
  String get name;

  const Task();

  Future<Object> execute(Context context);
}
