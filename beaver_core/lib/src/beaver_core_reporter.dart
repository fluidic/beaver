// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import './beaver_core_task_runner.dart';

abstract class Reporter {
  String get type;
}

class JsonReporter implements Reporter {
  @override
  String get type => 'json';

  final TaskRunResult _result;

  JsonReporter(this._result);

  String toJson() => JSON
      .encode({'status': taskStatusToString(_result.status), 'log': _result.log});
}
