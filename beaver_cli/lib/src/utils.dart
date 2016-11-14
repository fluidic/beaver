import 'dart:convert';

void prettyPrint(dynamic json, String indent) {
  JsonEncoder encoder = new JsonEncoder.withIndent(indent);
  String prettyprint = encoder.convert(json);
  print(prettyprint);
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();
