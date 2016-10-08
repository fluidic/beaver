import 'package:beaver_task/src/run.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import '../formatter.dart';

class TextFormatter implements Formatter {
  @override
  String get type => 'text';

  final List<TriggerResult> _results;

  TextFormatter(this._results);

  void _writeResult(TriggerResult result, StringBuffer buffer) {
    final items = {
      "Build Number": result.buildNumber.toString(),
      "TaskInstance Status": result.taskInstanceRunResult.status ==
          TaskInstanceStatus.success ? "Success" : "Failure",
      "Task Status": result.taskInstanceRunResult.taskRunResult.status ==
          TaskStatus.Success ? "Success" : "Failure",
      "Trigger Event": result.parsedTrigger.event,
      "Trigger URL": result.parsedTrigger.url,
      "Log": result.taskInstanceRunResult.taskRunResult.log,
    };
    final longestKeyLength = items.keys.fold(0, (num max, String keyString) {
      return keyString.length > max ? keyString.length : max;
    });
    items.forEach((String itemName, String itemContent) {
      buffer.writeln(
          " - ${itemName.padRight(longestKeyLength + 1)}: ${itemContent}");
    });
  }

  String toText() {
    final buffer = new StringBuffer();
    if (_results.length == 0) {
      return "No results found.";
    }

    buffer.writeln("${_results[0].project.name} (${_results[0].project.id})");
    _results.forEach((result) {
      _writeResult(result, buffer);
    });

    return buffer.toString();
  }
}
