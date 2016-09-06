import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import '../formatter.dart';

class TextFormatter implements Formatter {
  @override
  String get type => 'text';

  final TaskInstanceRunResult _result;

  TextFormatter(this._result);

  String toText() => _result.toString();
}
