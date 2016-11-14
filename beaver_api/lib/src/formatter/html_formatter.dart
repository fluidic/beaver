import 'package:beaver_store/beaver_store.dart';
import 'package:xml/xml.dart';

import '../formatter.dart';

class HtmlFormatter implements Formatter {
  @override
  String get type => 'html';

  final Project _project;
  final List<TriggerResult> _results;

  HtmlFormatter(this._project, this._results);

  void _buildTable(XmlBuilder builder) {
    builder.element('table', nest: () {
      builder.attribute('class', 'pure-table');
      _buildTableHeader(builder);
      builder.element('tbody', nest: () {
        _results.forEach((result) {
          _buildTableBodyRow(result, builder);
        });
      });
    });
  }

  void _buildTableHeader(XmlBuilder builder) {
    builder.element('thead', nest: () {
      builder.element('tr', nest: () {
        final columns = [
          '#',
          'Status',
          'Task Status',
          'Trigger Name',
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

  void _buildTableBodyRow(TriggerResult result, XmlBuilder builder) {
    builder.element('tr', nest: () {
      builder.element('td', nest: () {
        builder.text(result.buildNumber.toString());
      });
      builder.element('td', nest: () {
        builder.text(result.status);
      });
      builder.element('td', nest: () {
        if (result.taskRunResult != null) {
          builder.text(result.taskRunResult.toJson()['status']);
        } else {
          builder.text('');
        }
      });
      builder.element('td', nest: () {
        builder.text(result.trigger.name);
      });
      builder.element('td', nest: () {
        builder.text(result.parsedTrigger?.event);
      });
      builder.element('td', nest: () {
        builder.text(result.parsedTrigger?.url);
      });
      builder.element('td', nest: () {
        builder.text(result.taskRunResult?.log);
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
        if (_results.length == 0) {
          builder.element('h1', nest: () {
            builder.text('No results found.');
          });
        } else {
          builder.element('h1', nest: () {
            builder.text('${_project.name}');
          });
        }
        _buildTable(builder);
      });
    });
    return builder.build().toString();
  }
}
