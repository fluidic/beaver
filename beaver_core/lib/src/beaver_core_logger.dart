// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import './beaver_core_base.dart';

class SimpleLogger extends Logger {
  @override
  void log(LogLevel logLevel, message) {
    print('${logLevel}: ${message}');
  }
}

