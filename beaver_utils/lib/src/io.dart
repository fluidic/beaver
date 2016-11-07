import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Reads the contents of the text file [file].
Future<String> readTextFile(String file) =>
    new File(file).readAsString(encoding: UTF8);

/// Writes the [contents] to the text file [file].
Future<Null> writeTextFile(String file, String contents) async {
  await new File(file).writeAsString(contents, encoding: UTF8);
}
