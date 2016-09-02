import 'dart:async';

import '../model/project.dart';
import '../storage_service.dart';

class GCloudStorageService implements StorageService {
  @override
  Future<String> loadConfigFile(String projectId) {
    // TODO: implement loadConfigFile
  }

  @override
  Future<Project> loadProject(String projectId) {
    // TODO: implement loadProject
  }

  @override
  Future<Uri> saveConfigFile(String projectId, String config) {
    // TODO: implement saveConfigFile
  }

  @override
  Future<String> saveProject(Project project) {
    // TODO: implement saveProject
  }
}
