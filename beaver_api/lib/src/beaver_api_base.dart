import 'dart:async';
import 'dart:math';

import 'package:beaver_store/beaver_store.dart';

import './formatter/html_formatter.dart';
import './formatter/text_formatter.dart';

BeaverStore _beaverStore;

void initApiHandler(BeaverStore beaverStore) {
  _beaverStore = beaverStore;
}

Future<Map<String, Object>> apiHandler(
    String api, Map<String, Object> data) async {
  final context = await _createContext();

  final ret = {};
  switch (api) {
    case 'create':
      final projectName = data['project_name'];
      final config = data['config'];
      await _createProject(context, projectName, config: config);
      ret['project_name'] = projectName;
      break;
    case 'upload':
      // FIXME: Get file by a better way.
      final projectName = data['project_name'];
      final config = data['config'];
      await _uploadConfigFile(context, projectName, config);
      break;
    case 'get-results':
      final projectName = data['project_name'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final count = int.parse(data['count']);
      final result =
          await _getResult(context, projectName, buildNumber, format, count);
      ret['result'] = result;
      break;
    case 'delete':
      final projectName = data['project_name'];
      await _deleteProject(context, projectName);
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

class Context {
  // FIXME: Add logger.
  final BeaverStore beaverStore;
  Context(this.beaverStore);
}

Future<Context> _createContext() async {
  return new Context(_beaverStore);
}

/// Set new project. Returns the id of the registered project.
Future<Null> _createProject(Context context, String projectName,
    {String config}) async {
  await context.beaverStore.setNewProject(projectName);
  if (config != null) {
    await context.beaverStore.setConfig(projectName, config);
  }
}

Future<Null> _uploadConfigFile(
        Context context, String projectName, String config) =>
    context.beaverStore.setConfig(projectName, config);

Future<String> _getResult(Context context, String projectName, int buildNumber,
    String format, int count) async {
  final project = await context.beaverStore.getProject(projectName);
  final resultBuildNumbers =
      new Iterable.generate(max(count, 0), (i) => buildNumber + i);
  final results = (await Future.wait(resultBuildNumbers.map((number) async {
    try {
      return await context.beaverStore.getResult(projectName, number);
    } on NullThrownError {
      return null;
    }
  })))
      .toList()..removeWhere((result) => result == null);

  switch (format) {
    case 'html':
      final formatter = new HtmlFormatter(project, results);
      return formatter.toHtml();
    case 'text':
    default:
      final formatter = new TextFormatter(project, results);
      return formatter.toText();
  }
}

Future<Null> _deleteProject(Context context, String projectName) =>
    context.beaverStore.deleteProject(projectName);
