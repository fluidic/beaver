import 'dart:async';
import 'dart:io';

import 'package:which/which.dart';

const sshKeygenBinName = 'ssh-keygen';

String _sshKeyGenCache;

Future<String> _getSshKeygen() async {
  if (_sshKeyGenCache == null) {
    _sshKeyGenCache = await which(sshKeygenBinName);
  }
  return _sshKeyGenCache;
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> _splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();

class SshKeygenProcessResult {
  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  SshKeygenProcessResult(String stdout, String stderr, this.exitCode)
      : this.stdout = _toLines(stdout),
        this.stderr = _toLines(stderr);

  static List<String> _toLines(String output) {
    var lines = _splitLines(output);
    if (!lines.isEmpty && lines.last == "") lines.removeLast();
    return lines;
  }

  bool get success => exitCode == 0;
}

Future<SshKeygenProcessResult> runPub(List<String> args,
    {bool throwOnError: true, String processWorkingDir}) async {
  var sshKeygen = await _getSshKeygen();

  var result = await Process.run(sshKeygen, args,
      workingDirectory: processWorkingDir, runInShell: true);

  if (throwOnError) {
    _throwIfProcessFailed(result, sshKeygen, args);
  }

  return new SshKeygenProcessResult(
      result.stdout, result.stderr, result.exitCode);
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
