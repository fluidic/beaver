import 'dart:async';
import 'dart:io';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../model/project.dart';
import '../storage_service.dart';

final Map<String, Project> _projectMap = {};
final Map<String, TriggerResult> _resultMap = {};
final Map<String, int> _buildNumberMap = {};

class LocalMachineStorageService implements StorageService {
  const LocalMachineStorageService();

  @override
  Future<Project> loadProject(String projectId) async {
    return _projectMap[projectId];
  }

  @override
  Future<String> saveProject(Project project) async {
    if (project.id == null) {
      final id = new Uuid().v4();
      project.id = id;
    }
    _projectMap[project.id] = project;
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
    final dir = await _getProjectDir(projectId);
    final filePath = path.join(dir.path, 'beaver.yaml');
    final file = await new File(filePath).create();
    await file.writeAsString(config);
    return Uri.parse(filePath);
  }

  @override
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result) async {
    final key = projectId + '__' + buildNumber.toString();
    _resultMap[key] = result;
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectId, int buildNumber) async {
    final key = projectId + '__' + buildNumber.toString();
    return _resultMap[key];
  }

  Future<Directory> _getProjectDir(String projectId) async {
    final dirPath = path.join(Directory.systemTemp.path, projectId);
    return await new Directory(dirPath).create(recursive: true);
  }

  @override
  Future<int> getBuildNumber(String projectId) async {
    if (!_buildNumberMap.containsKey(projectId)) {
      _buildNumberMap[projectId] = 0;
    }
    return _buildNumberMap[projectId];
  }

  @override
  Future<bool> setBuildNumber(String projectId, int buildNumber) async {
    _buildNumberMap[projectId] = buildNumber;
    return true;
  }
}
