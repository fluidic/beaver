import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import '../formatter.dart';

class HtmlFormatter implements Formatter {
  @override
  String get type => 'html';

  final TriggerResult _result;

  HtmlFormatter(this._result);

  String toHtml() => throw new UnimplementedError();
}
