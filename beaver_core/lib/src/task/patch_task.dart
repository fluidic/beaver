import 'dart:async';
import 'dart:io';

import './shell_task.dart';
import '../annotation.dart';
import '../base.dart';

class PatchTaskException extends TaskException {
  final String _message;
  PatchTaskException(this._message);
  @override
  String toString() => _message;
}

/// Applies a diff file to originals.
@TaskClass('patch')
class PatchTask extends Task {
  /// The file that includes the diff output
  final String diffFile;

  /// Strip the smallest prefix containing num leading slashes from filenames.
  final int strip;

  /// The directory in which to run the patch command.
  final String directory;

  PatchTask(this.diffFile, {strip: 0, directory: ''})
      : strip = strip,
        directory = directory;

  @override
  Future<Object> execute(Context context) async {
    final file = new File(diffFile);
    if (!await file.exists()) {
      throw new PatchTaskException(
          'Patch file \'${diffFile}\' does not exist.');
    }

    // FIXME: Support Windows.
    final command = new StringBuffer('patch --strip=${strip} ');
    if (directory.isNotEmpty) {
      command.write('--directory=${directory} ');
    }
    command.write('< ${diffFile}');
    final task = new ShellTask('bash', ['-c', command.toString()]);
    await task.execute(context);
  }
}
