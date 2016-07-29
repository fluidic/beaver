import 'dart:async';
import 'dart:mirrors';

import './annotation.dart';

class TaskException implements Exception {}

abstract class Context {
  Configuration get configuration;
  Logger get logger;
  ContextPart getPart(String name);
}

abstract class ContextPart {
  String get name {
    var name;
    ClassMirror cm = reflect(this).type;
    cm.metadata.forEach((metadata) {
      name = metadata.reflectee.name;
    });
    return name;
  }

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

abstract class Configuration implements Map {}

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

