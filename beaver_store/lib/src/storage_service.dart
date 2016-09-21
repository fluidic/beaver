import 'dart:async';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

import './beaver_store_base.dart';
import './model/project.dart';
import './storage_service/gcloud_storage_service.dart';
import './storage_service/local_machine_storage_service.dart';

abstract class StorageService {
  Future<Project> loadProject(String projectId);
  Future<String> saveProject(Project project);

  Future<String> loadConfigFile(String projectId);
  Future<Uri> saveConfigFile(String projectId, String config);

  Future<int> getBuildNumber(String projectId);
  Future<bool> setBuildNumber(String projectId, int buildNumber);

  Future<TriggerResult> loadResult(String projectId, int buildNumber);
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result);
}

final Map<StorageServiceType, CreateStorageService> _map = {
  StorageServiceType.localMachine: () => new LocalMachineStorageService(),
  StorageServiceType.gCloud: () => new GCloudStorageService()
};

typedef StorageService CreateStorageService();

StorageService getStorageService(StorageServiceType type) {
  return _map[type]();
}
