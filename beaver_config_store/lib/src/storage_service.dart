import 'dart:async';

import './beaver_config_store_base.dart';
import './storage_service/gcloud_storage_service.dart';
import './storage_service/local_machine_storage_service.dart';
import './model/project.dart';

abstract class StorageService {
  Future<Project> loadProject(String projectId);
  Future<String> saveProject(Project project);

  Future<String> loadConfigFile(String projectId);
  Future<Uri> saveConfigFile(String projectId, String config);
}

final Map<StorageServiceType, CreateStorageService> _map = {
  StorageServiceType.localMachine: () => new LocalMachineStorageService(),
  StorageServiceType.gCloud: () => new GCloudStorageService()
};

typedef StorageService CreateStorageService();

StorageService getStorageService(StorageServiceType type) {
  return _map[type]();
}
