// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:which/which.dart';

const gcloudBinName = 'gcloud';

String _gcloudCache;

Future<String> _getGCloud() async {
  if (_gcloudCache == null) {
    _gcloudCache = await which(gcloudBinName);
  }
  return _gcloudCache;
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> _splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();

class GCloudProcessResult {
  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  GCloudProcessResult(String stdout, String stderr, this.exitCode)
      : this.stdout = _toLines(stdout),
        this.stderr = _toLines(stderr);

  static List<String> _toLines(String output) {
    var lines = _splitLines(output);
    if (!lines.isEmpty && lines.last == "") lines.removeLast();
    return lines;
  }

  bool get success => exitCode == 0;
}

Future<GCloudProcessResult> runGCloud(List<String> args,
    {bool throwOnError: true, String processWorkingDir}) async {
  var gcloud = await _getGCloud();

  var result = await Process.run(gcloud, args,
      workingDirectory: processWorkingDir, runInShell: true);

  if (throwOnError) {
    _throwIfProcessFailed(result, gcloud, args);
  }

  return new GCloudProcessResult(result.stdout, result.stderr, result.exitCode);
}

void _throwIfProcessFailed(
    ProcessResult pr, String process, List<String> args) {
  assert(pr != null);
  if (pr.exitCode != 0) {
    var message = '''
stdout:
${pr.stdout}
stderr:
${pr.stderr}''';

    throw new ProcessException(process, args, message, pr.exitCode);
  }
}
