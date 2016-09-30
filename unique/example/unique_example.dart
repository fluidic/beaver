// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:unique/unique.dart';

main() {
  String name = uniqueName(prefix: 'foo');
  print(name);
}
