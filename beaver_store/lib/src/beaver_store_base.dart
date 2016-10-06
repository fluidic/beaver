import 'dart:async';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import './model/config.dart';
import './model/project.dart';
import './storage_service.dart';

enum StorageServiceType { localMachine, gCloud }

class BeaverStore {
  final StorageService _storageService;

  BeaverStore(StorageServiceType storageServiceType)
      : _storageService = getStorageService(storageServiceType);

  Future<Null> init() async {
    await _storageService.init(new Map());
  }

  /// Return the id of Project.
  Future<String> setNewProject(String name) {
    return _storageService.saveProject(new Project(name));
  }

  Future<Project> getProject(String id) {
    return _storageService.loadProject(id);
  }

  Future<int> getAndUpdateBuildNumber(String id) async {
    final buildNumber = await _storageService.getBuildNumber(id);
    await _storageService.setBuildNumber(id, buildNumber + 1);
    return buildNumber;
  }

  Future<Null> setConfig(String id, String yaml) async {
    final config = new YamlConfig(yaml);
    final project = await _storageService.loadProject(id);
    if (project == null) {
      throw new Exception('No project for ${id}');
    }
    if (project.name != config['project_name']) {
      throw new Exception('Project name is not valid.');
    }
    project.config = config;
    await _storageService.saveProject(project);
  }

  Future<Null> saveResult(
      String id, int buildNumber, TriggerResult result) async {
    await _storageService.saveResult(id, buildNumber, result);
  }

  Future<TriggerResult> getResult(String id, int buildNumber) =>
      _storageService.loadResult(id, buildNumber);
}
