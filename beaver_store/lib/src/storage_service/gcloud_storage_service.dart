import 'dart:async';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';

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

  @override
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result) {
    // TODO: implement saveResult
  }

  @override
  Future<TriggerResult> loadResult(String projectId, int buildNumber) {
    // TODO: implement getResult
  }

  @override
  Future<int> getBuildNumber(String projectId) {
    // TODO: implement getBuildNumber
  }

  @override
  Future<bool> setBuildNumber(String projectId, int buildNumber) {
    // TODO: implement setBuildNumber
  }
}
