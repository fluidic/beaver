import 'dart:async';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import './model/config.dart';
import './model/project.dart';
import './model/trigger_result.dart';
import './storage_service.dart';

enum StorageServiceType { localMachine, gCloud }

class BeaverStore {
  final StorageService _storageService;

  BeaverStore(StorageServiceType storageServiceType)
      : _storageService = getStorageService(storageServiceType);

  Future<Null> initialize(Map<String, Object> config) =>
      _storageService.initialize(config);

  Future<Null> setNewProject(String name) async {
    final project = await _storageService.loadProject(name);
    if (project != null) {
      throw new Exception('Project \'${name}\' already exists.');
    }
    await _storageService.saveProject(new Project(name));
  }

  Future<Project> getProject(String name) => _storageService.loadProject(name);

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
      String id,
      int buildNumber,
      Trigger trigger,
      ParsedTrigger parsedTrigger,
      Map<String, Object> taskInstance,
      TaskInstanceRunResult taskInstanceRunResult) async {
    final result = new TriggerResult.fromTriggerHandler(id, buildNumber,
        trigger, parsedTrigger, taskInstance, taskInstanceRunResult);
    await _storageService.saveResult(id, buildNumber, result);
  }

  Future<TriggerResult> getResult(String id, int buildNumber) =>
      _storageService.loadResult(id, buildNumber);
}

Future<BeaverStore> getBeaverStore(StorageServiceType type,
    {Map<String, Object> config}) async {
  final beaverStore = new BeaverStore(type);
  await beaverStore.initialize(config);
  return beaverStore;
}
