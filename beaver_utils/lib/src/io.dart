import 'dart:convert';
import 'dart:io';

/// Reads the contents of the text file [file].
String readTextFile(String file) =>
    new File(file).readAsStringSync(encoding: UTF8);

/// Writes the [contents] to the text file [file].
void writeTextFile(String file, String contents) =>
    new File(file).writeAsStringSync(contents, encoding: UTF8);
