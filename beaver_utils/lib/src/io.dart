import 'dart:convert';
import 'dart:io';

/// Reads the contents of the text file [file].
String readTextFile(String file) =>
    new File(file).readAsStringSync(encoding: UTF8);
