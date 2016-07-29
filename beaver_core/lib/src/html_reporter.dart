import './base.dart';
import './task_runner.dart';

class HtmlReporter implements Reporter {
  @override
  String get type => 'html';

  final TaskRunResult _result;

  HtmlReporter(this._result);

  String toHtml() => throw new UnimplementedError();
}

