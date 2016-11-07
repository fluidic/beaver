import 'dart:math';

final Random _rnd = new Random.secure();

final List<int> _letters = 'abcdefghijklmnopqrstuvwxyz'.codeUnits;

const int _defaultLength = 10;

/// Returns a unique name with the given [prefix] and [length].
/// Note that the length of prefix is not included in counting the [length].
String uniqueName({String prefix: '', int length: _defaultLength}) {
  List<int> charCodes = new List<int>(length);
  for (var i = 0; i < charCodes.length; i++) {
    charCodes[i] = _letters[_rnd.nextInt(_letters.length)];
  }
  return '$prefix${new String.fromCharCodes(charCodes)}';
}
