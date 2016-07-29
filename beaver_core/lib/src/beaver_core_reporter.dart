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
