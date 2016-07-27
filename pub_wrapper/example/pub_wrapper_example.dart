// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:pub_wrapper/pub_wrapper.dart';

main() async {
  final result = await runPub(['get']);
  print(result.stdout);
  print(result.stderr);
}

