// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:which/which.dart';

const pubBinName = 'pub';

String _pubCache;

Future<String> _getPub() async {
  if (_pubCache == null) {
    _pubCache = await which(pubBinName);
  }
  return _pubCache;
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> _splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();

class PubProcessResult {
  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  PubProcessResult(String stdout, String stderr, this.exitCode)
      : this.stdout = _toLines(stdout),
        this.stderr = _toLines(stderr);

  static List<String> _toLines(String output) {
    var lines = _splitLines(output);
    if (!lines.isEmpty && lines.last == "") lines.removeLast();
    return lines;
  }

  bool get success => exitCode == 0;
}

Future<PubProcessResult> runPub(List<String> args,
    {bool throwOnError: true, String processWorkingDir}) async {
  var pub = await _getPub();

  var result = await Process.run(pub, args,
      workingDirectory: processWorkingDir, runInShell: true);

  if (throwOnError) {
    _throwIfProcessFailed(result, pub, args);
  }

  return new PubProcessResult(result.stdout, result.stderr, result.exitCode);
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
