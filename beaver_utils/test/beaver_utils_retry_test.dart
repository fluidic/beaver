import 'dart:async';

import 'package:beaver_utils/beaver_utils.dart';
import 'package:test/test.dart';

typedef Future<int> Callback();

Callback makeFunctionThrowingNTimes(int n) {
  return () async {
    n--;
    if (n >= 0) throw new Exception();
    return 0;
  };
}

void main() {
  group('retry tests', () {
    test('retry success', () {
      retry(3, new Duration(seconds: 1), makeFunctionThrowingNTimes(2))
          .then((value) => expect(value, 0));
    });

    test('retry failure', () {
      expect(retry(3, new Duration(seconds: 1), makeFunctionThrowingNTimes(3)),
          throwsException);
    });
  });
}
