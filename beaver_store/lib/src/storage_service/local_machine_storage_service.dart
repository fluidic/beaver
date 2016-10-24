import 'dart:async';

import 'package:quiver_iterables/iterables.dart';

import '../model/project.dart';
import '../model/trigger_result.dart';
import '../storage_service.dart';

final Map<String, Project> _projectMap = {};
final Map<String, TriggerResult> _resultMap = {};
final Map<String, int> _buildNumberMap = {};

class LocalMachineStorageService implements StorageService {
  const LocalMachineStorageService();

  @override
  Future<Project> loadProject(String projectName) async {
    return _projectMap[projectName];
  }

  @override
  Future<Null> saveProject(Project project) async {
    _projectMap[project.name] = project;
  }

  @override
  Future<bool> saveResult(
      String projectName, int buildNumber, TriggerResult result) async {
    final key = projectName + '__' + buildNumber.toString();
    _resultMap[key] = result;
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectName, int buildNumber) async {
    final key = projectName + '__' + buildNumber.toString();
    return _resultMap[key];
  }

  @override
  Future<int> getBuildNumber(String projectName) async {
    if (!_buildNumberMap.containsKey(projectName)) {
      _buildNumberMap[projectName] = 0;
    }
    return _buildNumberMap[projectName];
  }

  @override
  Future<bool> setBuildNumber(String projectName, int buildNumber) async {
    _buildNumberMap[projectName] = buildNumber;
    return true;
  }

  @override
  Future<Null> initialize(Map<String, String> config) => null;

  @override
  Future<Null> removeProject(String projectName) async {
    _projectMap.remove(projectName);
    _buildNumberMap.remove(projectName);
  }

  @override
  Future<Null> removeResult(String projectName) async {
    final buildNumber = await getBuildNumber(projectName);
    if (buildNumber == null) {
      return;
    }
    for (final num in range(0, buildNumber + 1)) {
      final key = projectName + '__' + num.toString();
      _resultMap.remove(key);
    }
  }

  @override
  Future<Iterable<Project>> listProjects() async {
    return _projectMap.values;
  }
}
