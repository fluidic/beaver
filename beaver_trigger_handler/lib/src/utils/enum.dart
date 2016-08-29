String enumName(enumValue) {
  final s = enumValue.toString();
  return s.substring(s.indexOf('.') + 1);
}
