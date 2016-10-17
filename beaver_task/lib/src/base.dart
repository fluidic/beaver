import 'dart:async';

import 'package:logging/logging.dart';

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

/// Config contains information required to run tasks on the cloud.
class Config {
  /// The type of cloud service. Currently, only 'gcloud' is supported.
  final String cloudType;

  /// The settings for the cloud. The keys are specific to each cloud type.
  final Map<String, String> cloudSettings;

  Config(this.cloudType, this.cloudSettings);
}

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


