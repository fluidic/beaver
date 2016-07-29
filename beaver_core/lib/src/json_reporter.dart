import 'dart:convert';

import './base.dart';
import './task_runner.dart';

class JsonReporter implements Reporter {
  @override
  String get type => 'json';

  final TaskRunResult _result;

  JsonReporter(this._result);

  String toJson() => JSON.encode(
      {'status': taskStatusToString(_result.status), 'log': _result.log});
}

