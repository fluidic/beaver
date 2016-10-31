import 'package:beaver_utils/beaver_utils.dart';
import 'package:test/test.dart';

enum TestEnum {
  foo,
  bar
}

void main() {
  group('EnumCodec tests', () {
    test('EnumFromString', () {
      final converter = new EnumFromString<TestEnum>();
      expect(converter.convert('foo'), TestEnum.foo);
      expect(converter.convert('bar'), TestEnum.bar);
    });

    test('EnumToString', () {
      final converter = new EnumToString<TestEnum>();
      expect(converter.convert(TestEnum.foo), 'foo');
      expect(converter.convert(TestEnum.bar), 'bar');
    });
  });
}

