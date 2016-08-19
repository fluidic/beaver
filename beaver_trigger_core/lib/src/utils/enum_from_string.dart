import '../base.dart';

SourceType sourceTypeFromString(String str) {
  return SourceType.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == str.toUpperCase());
}
