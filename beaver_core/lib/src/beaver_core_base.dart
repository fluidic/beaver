// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

class TaskException implements Exception {}

abstract class Context {
  Configuration get configuration;
  Logger get logger;
  ContextPart getPart(String name);
}

abstract class ContextPart {
  String get name;
  Future<Null> setUp(Configuration conf);
  Future<Null> tearDown();
}

enum LogLevel { INFO, WARN, ERROR }

// FIXME: Add more methods from https://www.dartdocs.org/documentation/logging
abstract class Logger {
  const Logger();

  void log(LogLevel level, message);

  void info(message) => log(LogLevel.INFO, message);
  void warn(message) => log(LogLevel.WARN, message);
  void error(message) => log(LogLevel.ERROR, message);
}

abstract class Configuration implements Map {
}


abstract class Task {
  String get name;

  const Task();

  Future<Object> execute(Context context);

  factory Task.fromFunc(ExecuteFunc func) => new _LambdaTask(func);
}

typedef Future<Object> ExecuteFunc(Context context);

class _LambdaTask implements Task {
  @override
  String get name => 'lambda_task';

  final ExecuteFunc _func;

  _LambdaTask(this._func);

  @override
  Future<Object> execute(Context context) => _func(context);
}

