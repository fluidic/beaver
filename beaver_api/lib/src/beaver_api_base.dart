import 'dart:async';

import 'package:beaver_store/beaver_store.dart';

// FIXME: Don't use ConnectorType.mapInMemory here.
final _projectStore = new ProjectStore(ConnectorType.mapInMemory);

/// Set new project. Returns the id of the registered project.
Future<String> registerProject(String projectName, String config) async {
  final projectId = await _projectStore.setNewProject(projectName);
  await _projectStore.setConfig(projectId, config);
  return projectId;
}

Future<Null> uploadConfigFile(String projectId, String config) =>
    _projectStore.setConfig(projectId, config);

// FIXME: Implement API for getting results.
