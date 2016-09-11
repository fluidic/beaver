import 'package:beaver_task/src/run.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import '../formatter.dart';

class TextFormatter implements Formatter {
  @override
  String get type => 'text';

  final TriggerResult _result;

  TextFormatter(this._result);

  String toText() {
    final buffer = new StringBuffer();

    buffer.writeln("${_result.project.name} (${_result.project.id})");

    final items = {
      "Build Number": _result.project.buildNumber.toString(),
      "TaskInstance Status": _result.taskInstanceRunResult.status ==
          TaskInstanceStatus.success ? "Success" : "Failure",
      "Task Status": _result.taskInstanceRunResult.taskRunResult.status ==
          TaskStatus.Success ? "Success" : "Failure",
      "Trigger Event": _result.parsedTrigger.event,
      "Trigger URL": _result.parsedTrigger.url,
      "Log": _result.taskInstanceRunResult.taskRunResult.log,
    };

    final longestKeyLength = items.keys.fold(0, (num max, String keyString) {
      return keyString.length > max ? keyString.length : max;
    });
    items.forEach((String itemName, String itemContent) {
      buffer.writeln(
          " - ${itemName.padRight(longestKeyLength + 1)}: ${itemContent}");
    });

    return buffer.toString();
  }
}
