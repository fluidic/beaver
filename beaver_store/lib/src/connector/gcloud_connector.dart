import 'dart:async';

import '../connector.dart';
import '../model/project.dart';

class GCloudConnector implements Connector {
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
