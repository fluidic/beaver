import 'dart:io';

import 'package:args/command_runner.dart';
import "package:http/http.dart" as http;
import "package:yaml/yaml.dart";

/// An exception class for exceptions that are intended to be seen by the user.
///
/// These exceptions won't have any debugging information printed when they're
/// thrown.
class ApplicationException implements Exception {
  final String message;

  ApplicationException(this.message);

  @override
  String toString() => message;
}

/// Returns whether [error] is a user-facing error object.
///
/// This includes both [ApplicationException] and any dart:io errors.
bool isUserFacingException(error) {
  return error is ApplicationException ||
      error is IOException ||
      error is http.ClientException ||
      error is YamlException ||
      error is UsageException;
}
