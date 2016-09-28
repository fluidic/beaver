// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:which/which.dart';

const gsutilBinName = 'gsutil';

String _gsutilCache;

Future<String> _getGSUtil() async {
  if (_gsutilCache == null) {
    _gsutilCache = await which(gsutilBinName);
  }
  return _gsutilCache;
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> _splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();

class GSUtilProcessResult {
  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  GSUtilProcessResult(String stdout, String stderr, this.exitCode)
      : this.stdout = _toLines(stdout),
        this.stderr = _toLines(stderr);

  static List<String> _toLines(String output) {
    var lines = _splitLines(output);
    if (!lines.isEmpty && lines.last == "") lines.removeLast();
    return lines;
  }

  bool get success => exitCode == 0;
}

Future<GSUtilProcessResult> runGSUtil(List<String> args,
    {bool throwOnError: true, String processWorkingDir}) async {
  var gsutil = await _getGSUtil();

  var result = await Process.run(gsutil, args,
      workingDirectory: processWorkingDir, runInShell: true);

  if (throwOnError) {
    _throwIfProcessFailed(result, gsutil, args);
  }

  return new GSUtilProcessResult(result.stdout, result.stderr, result.exitCode);
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
