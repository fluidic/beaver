import 'dart:async';
import 'dart:math';

import 'package:beaver_store/beaver_store.dart';

import './formatter/html_formatter.dart';
import './formatter/text_formatter.dart';

Future<Map<String, Object>> apiHandler(
    String api, Map<String, Object> data) async {
  final ret = {};
  switch (api) {
    case 'register':
      final projectName = data['project'];
      final config = data['config'];
      final id = await _registerProject(projectName, config);
      ret['project'] = projectName;
      ret['id'] = id;
      break;
    case 'upload':
      // FIXME: Get file by a better way.
      final projectId = data['id'];
      final config = data['config'];
      await _uploadConfigFile(projectId, config);
      break;
    case 'result':
      final projectId = data['id'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final count = int.parse(data['count']);
      final result = await _getResult(projectId, buildNumber, format, count);
      ret['result'] = result;
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

// FIXME: Don't use StorageServiceType.localMachine here.
final _beaverStore = new BeaverStore(StorageServiceType.localMachine);

Future<Null> initApiHandler() async {
  await _beaverStore.init();
}

/// Set new project. Returns the id of the registered project.
Future<String> _registerProject(String projectName, String config) async {
  final projectId = await _beaverStore.setNewProject(projectName);
  await _beaverStore.setConfig(projectId, config);
  return projectId;
}

Future<Null> _uploadConfigFile(String projectId, String config) =>
    _beaverStore.setConfig(projectId, config);

Future<String> _getResult(
    String projectId, int buildNumber, String format, int count) async {
  // FIXME: When count is bigger than buildNumber + 1, minus value is created.
  final targetBuildNumbers = new Iterable.generate(
      min(buildNumber + 1, count), (i) => buildNumber - i);
  final results = await Future.wait(targetBuildNumbers
      .map((targetNumber) => _beaverStore.getResult(projectId, targetNumber)));
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
