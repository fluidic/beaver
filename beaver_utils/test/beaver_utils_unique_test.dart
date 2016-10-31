import 'package:beaver_utils/beaver_utils.dart';
import 'package:test/test.dart';

void main() {
  group('uniqueName tests', () {
    test('prefix', () {
      expect(uniqueName(prefix: 'foo'), startsWith('foo'));
    });

    test('length', () {
      expect(uniqueName(length: 10), hasLength(10));
      expect(uniqueName(length: 20), hasLength(20));
    });

    test('uniqueness', () {
      const n = 8192;
      final nameSet = new Set();
      for (var i = 0; i < n; i++) {
        nameSet.add(uniqueName());
      }
      expect(nameSet.length, n);
    });
  });
}

