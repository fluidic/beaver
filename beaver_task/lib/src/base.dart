import 'dart:async';
import 'dart:convert';

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

  factory Config.fromJson(json) {
    if (json is String) {
      json = JSON.decode(json);
    }
    if (json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    final cloudType = json['cloud_type'];
    final cloudSettings = json['cloud_settings'] as Map<String, String>;
    if (cloudType == null || cloudSettings == null) {
      throw new ArgumentError('The given json does not contain all the fields');
    }
    return new Config(cloudType, cloudSettings);
  }

  Map toJson() => {'cloud_type': cloudType, 'cloud_settings': cloudSettings};
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
