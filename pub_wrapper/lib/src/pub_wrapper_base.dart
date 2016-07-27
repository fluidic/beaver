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

Future<ProcessResult> runPub(List<String> args,
    {bool throwOnError: true, String processWorkingDir}) async {
  var git = await _getPub();

  var pr = await Process.run(git, args,
      workingDirectory: processWorkingDir, runInShell: true);

  if (throwOnError) {
    _throwIfProcessFailed(pr, git, args);
  }
  return pr;
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

