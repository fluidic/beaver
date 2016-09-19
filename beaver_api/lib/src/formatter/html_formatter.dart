import 'package:beaver_task/beaver_task_runner.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:xml/xml.dart';

import '../formatter.dart';

class HtmlFormatter implements Formatter {
  @override
  String get type => 'html';

  final TriggerResult _result;

  HtmlFormatter(this._result);

  void _buildTable(XmlBuilder builder) {
    builder.element('table', nest: () {
      builder.attribute('class', 'pure-table');
      _buildTableHeader(builder);
      _buildTableBody(builder);
    });
  }

  void _buildTableHeader(XmlBuilder builder) {
    builder.element('thead', nest: () {
      builder.element('tr', nest: () {
        final columns = [
          '#',
          'TaskInstance Status',
          'Task Status',
          'Trigger Event',
          'Trigger URL',
          'Log',
        ];
        columns.forEach((columnName) {
          builder.element('th', nest: () {
            builder.text(columnName);
          });
        });
      });
    });
  }

  void _buildTableBody(XmlBuilder builder) {
    builder.element('tbody', nest: () {
      builder.element('tr', nest: () {
        builder.element('td', nest: () {
          builder.text(_result.project.buildNumber.toString());
        });
        builder.element('td', nest: () {
          builder.text(_result.taskInstanceRunResult.status ==
              TaskInstanceStatus.success ? "Success" : "Failure");
        });
        builder.element('td', nest: () {
          builder.text(_result.taskInstanceRunResult.taskRunResult.status ==
              TaskStatus.Success ? "Success" : "Failure");
        });
        builder.element('td', nest: () {
          builder.text(_result.parsedTrigger.event);
        });
        builder.element('td', nest: () {
          builder.text(_result.parsedTrigger.url);
        });
        builder.element('td', nest: () {
          builder.text(_result.taskInstanceRunResult.taskRunResult.log);
        });
      });
    });
  }

  String toHtml() {
    final builder = new XmlBuilder();
    builder.element('html', nest: () {
      builder.element('head', nest: () {
        builder.element('link', nest: () {
          builder.attribute('rel', 'stylesheet');
          builder.attribute(
              'href', 'http://yui.yahooapis.com/pure/0.6.0/tables-min.css');
        });
      });
      builder.element('body', nest: () {
        builder.element('h1', nest: () {
          builder.text('${_result.project.name} (${_result.project.id})');
        });
        _buildTable(builder);
      });
    });
    return builder.build().toString();
  }
}
