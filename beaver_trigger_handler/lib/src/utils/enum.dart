import '../base.dart';

SourceType sourceTypeFromString(String str) {
  return SourceType.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == str.toUpperCase());
}

String enumName(enumValue) {
  final s = enumValue.toString();
  return s.substring(s.indexOf('.') + 1);
}
