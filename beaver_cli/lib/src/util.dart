import 'dart:convert';

void prettyPrint(dynamic json, String indent) {
  JsonEncoder encoder = new JsonEncoder.withIndent(indent);
  String prettyprint = encoder.convert(json);
  print(prettyprint);
}