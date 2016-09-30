// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:unique/unique.dart';
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

