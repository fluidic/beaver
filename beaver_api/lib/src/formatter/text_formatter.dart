import 'package:beaver_store/beaver_store.dart';

import '../formatter.dart';

class TextFormatter implements Formatter {
  @override
  String get type => 'text';

  final Project _project;
  final List<TriggerResult> _results;

  TextFormatter(this._project, this._results);

  void _writeResult(TriggerResult result, StringBuffer buffer) {
    final items = {
      "Build Number": result.buildNumber.toString(),
      "TaskInstance Status": result.taskInstanceStatus,
      "Task Status": result.taskStatus,
      "Trigger Event": result.parsedTriggerEvent,
      "Trigger URL": result.parsedTriggerUrl,
      "Log": result.taskLog,
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

    buffer.writeln("${_project.name}");
    _results.forEach((result) {
      _writeResult(result, buffer);
    });

    return buffer.toString();
  }
}
