import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<Null> createFileIfNotExist(String file) async {
  await new File(file).create();
}

/// Reads the contents of the text file [file].
Future<String> readTextFile(String file) =>
    new File(file).readAsString(encoding: UTF8);

/// Writes the [contents] to the text file [file].
Future<Null> writeTextFile(String file, String contents) async {
  await new File(file).writeAsString(contents, encoding: UTF8);
}

Future chmod(String mode, File file) =>
    Process.run('chmod', [mode, file.path]).then((result) {
      if (result.exitCode != 0) throw new Exception(result.stderr);
    });

