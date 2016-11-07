import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';

// An exception class for exceptions that are intended to be seen by the user.
//
// These exceptions won't have any debugging information printed when they're
// thrown.
class TaskException implements Exception {
  final String message;

  TaskException(this.message);

  @override
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

  /// The information on build.
  final Map<String, String> buildInfo;

  Config(this.cloudType, this.cloudSettings, this.buildInfo);

  factory Config.fromJson(json) {
    if (json is String) {
      json = JSON.decode(json);
    }
    if (json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    final cloudType = json['cloud_type'];
    final cloudSettings = json['cloud_settings'] as Map<String, String>;
    final buildInfo = json['build_info'] as Map<String, String>;
    if (cloudType == null || cloudSettings == null || buildInfo == null) {
      throw new ArgumentError('The given json does not contain all the fields');
    }
    return new Config(cloudType, cloudSettings, buildInfo);
  }

  Map toJson() => {
        'cloud_type': cloudType,
        'cloud_settings': cloudSettings,
        'build_info': buildInfo
      };
}
