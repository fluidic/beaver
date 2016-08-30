import 'dart:async';

import 'package:beaver_store/beaver_store.dart';

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
    case 'results':
      // FIXME: Implement.
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

// FIXME: Don't use ConnectorType.mapInMemory here.
final _projectStore = new ProjectStore(ConnectorType.mapInMemory);

/// Set new project. Returns the id of the registered project.
Future<String> _registerProject(String projectName, String config) async {
  final projectId = await _projectStore.setNewProject(projectName);
  await _projectStore.setConfig(projectId, config);
  return projectId;
}

Future<Null> _uploadConfigFile(String projectId, String config) =>
    _projectStore.setConfig(projectId, config);

// FIXME: Implement API for getting results.
