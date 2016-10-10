import 'dart:async';
import 'dart:math';

import 'package:beaver_store/beaver_store.dart';

import './formatter/html_formatter.dart';
import './formatter/text_formatter.dart';

Future<Map<String, Object>> apiHandler(
    String api, Map<String, Object> data) async {
  final context = await _createContext();

  final ret = {};
  switch (api) {
    case 'register':
      final projectName = data['project'];
      final config = data['config'];
      final id = await _registerProject(context, projectName, config);
      ret['project'] = projectName;
      ret['id'] = id;
      break;
    case 'upload':
      // FIXME: Get file by a better way.
      final projectId = data['id'];
      final config = data['config'];
      await _uploadConfigFile(context, projectId, config);
      break;
    case 'result':
      final projectId = data['id'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final count = int.parse(data['count']);
      final result =
          await _getResult(context, projectId, buildNumber, format, count);
      ret['result'] = result;
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

class Context {
  final BeaverStore beaverStore;
  Context(this.beaverStore);
}

Future<Context> _createContext() async {
  // FIXME: Don't use StorageServiceType.localMachine here.
  final beaverStore = await getBeaverStore(StorageServiceType.localMachine);
  return new Context(beaverStore);
}

/// Set new project. Returns the id of the registered project.
Future<String> _registerProject(
    Context context, String projectName, String config) async {
  final projectId = await context.beaverStore.setNewProject(projectName);
  await context.beaverStore.setConfig(projectId, config);
  return projectId;
}

Future<Null> _uploadConfigFile(
        Context context, String projectId, String config) =>
    context.beaverStore.setConfig(projectId, config);

Future<String> _getResult(Context context, String projectId, int buildNumber,
    String format, int count) async {
  final resultBuildNumbers =
      new Iterable.generate(max(count, 0), (i) => buildNumber + i);
  final results = (await Future.wait(resultBuildNumbers.map((number) async {
    try {
      return await context.beaverStore.getResult(projectId, number);
    } on NullThrownError {
      return null;
    }
  })))
      .toList()..removeWhere((result) => result == null);

  switch (format) {
    case 'html':
      final formatter = new HtmlFormatter(results);
      return formatter.toHtml();
    case 'text':
    default:
      final formatter = new TextFormatter(results);
      return formatter.toText();
  }
}
