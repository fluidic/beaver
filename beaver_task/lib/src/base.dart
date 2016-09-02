import 'dart:async';

import './annotation.dart';

// An exception class for exceptions that are intended to be seen by the user.
//
// These exceptions won't have any debugging information printed when they're
// thrown.
class TaskException implements Exception {
  final String message;

  TaskException(this.message);

  String toString() => message;
}

abstract class Context {
  Config get config;
  Logger get logger;
  ContextPart getPart(String name);
}

abstract class ContextPart {
  Future<Null> setUp(Config conf);
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

abstract class Config implements Map {}

abstract class Task {
  const Task();

  Future<Object> execute(Context context);

  factory Task.fromFunc(ExecuteFunc func) => new _LambdaTask(func);
}

typedef Future<Object> ExecuteFunc(Context context);

@TaskClass('lambda')
class _LambdaTask implements Task {
  final ExecuteFunc _func;

  _LambdaTask(this._func);

  @override
  Future<Object> execute(Context context) => _func(context);
}

abstract class Reporter {
  String get type;
}

