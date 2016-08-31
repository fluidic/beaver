import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../connector.dart';
import '../model/project.dart';

final Map<String, Project> _map = {};

class LocalMachineConnector implements Connector {
  const LocalMachineConnector();

  @override
  Future<Project> loadProject(String projectId) async {
    return _map[projectId];
  }

  @override
  Future<String> saveProject(Project project) async {
    if (project.id == null) {
      final id = new Uuid().v4();
      project.id = id;
    }
    _map[project.id] = project;
    return project.id;
  }

  @override
  Future<String> loadConfigFile(String projectId) async {
    final project = await loadProject(projectId);
    final file = new File(project.configFile.path);
    final config = await file.readAsString();
    return config;
  }

  @override
  Future<Uri> saveConfigFile(String projectId, String config) async {
    final dirPath = path.join(Directory.systemTemp.path, projectId);
    await new Directory(dirPath).create(recursive: true);
    final filePath = path.join(dirPath, 'beaver.yaml');
    final file = await new File(filePath).create();
    await file.writeAsString(config);
    return Uri.parse(filePath);
  }
}
