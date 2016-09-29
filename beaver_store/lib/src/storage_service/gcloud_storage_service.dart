import 'dart:async';

import 'package:beaver_gcloud/src/gcloud_mixin.dart';
import 'package:beaver_store/src/model/config.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:gcloud/datastore.dart' as datastore;

import '../model/project.dart';
import '../storage_service.dart';
import 'gcloud_model/project.dart';

class GCloudStorageService extends Object
    with GCloudMixin
    implements StorageService {
  Future<String> _allocateProjectId() async {
    final keyElement = new datastore.KeyElement('BeaverProject', null);
    final key = new datastore.Key([keyElement]);
    final populatedKey = (await db.datastore.allocateIds([key])).first;
    return populatedKey.elements.first.id.toString();
  }

  Future<BeaverProject> _queryProjectModel(String projectId) async {
    final query = db.query(BeaverProject)..filter('projectId =', projectId);
    return query.run().first;
  }

  @override
  Future<String> loadConfigFile(String projectId) {
    // TODO: implement loadConfigFile
  }

  @override
  Future<Uri> saveConfigFile(String projectId, String config) {
    // TODO: implement saveConfigFile
  }

  @override
  Future<Project> loadProject(String projectId) async {
    final projectModel = await _queryProjectModel(projectId);
    return new Project(projectModel.name)
      ..id = projectModel.projectId
      ..config = new YamlConfig(projectModel.config);
  }

  @override
  Future<String> saveProject(Project project) async {
    final projectModel = project.id == null
        ? (new BeaverProject()
          ..projectId = await _allocateProjectId()
          ..buildNumber = 0)
        : await _queryProjectModel(project.id);
    projectModel
      ..name = project.name
      ..config = project.config.toString();
    await db.commit(inserts: [projectModel]);
    return projectModel.projectId;
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

  @override
  Future<Null> init(Map<String, String> config) => super.init(config);
}
