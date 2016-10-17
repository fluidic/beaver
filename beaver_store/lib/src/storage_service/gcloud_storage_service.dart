import 'dart:async';
import 'dart:convert';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:gcloud/datastore.dart' as datastore;

import '../model/config.dart';
import '../model/project.dart';
import '../model/trigger_result.dart';
import '../storage_service.dart';
import 'gcloud_model/build.dart';
import 'gcloud_model/project.dart';

class GCloudStorageService extends Object
    with GCloudMixin
    implements StorageService {
  Future<int> _allocateProjectId() async {
    final keyElement = new datastore.KeyElement('BeaverProject', null);
    final key = new datastore.Key([keyElement]);
    final populatedKey = (await db.datastore.allocateIds([key])).first;
    return populatedKey.elements.first.id;
  }

  Future<BeaverProject> _queryProjectModel(String projectId) async {
    final datastoreKey =
        new datastore.Key.fromParent('BeaverProject', int.parse(projectId));
    final key = db.modelDB.fromDatastoreKey(datastoreKey);
    final query = db.query(BeaverProject, ancestorKey: key);
    return await query.run().first;
  }

  Future<BeaverBuild> _queryBuildModel(
      String projectId, int buildNumber) async {
    final query = db.query(BeaverBuild)
      ..filter('projectId =', projectId)
      ..filter('number =', buildNumber);
    final result = await query.run().toList();
    return result.length == 0 ? null : result.first as BeaverBuild;
  }

  @override
  Future<Project> loadProject(String projectId) async {
    final projectModel = await _queryProjectModel(projectId);
    return new Project(projectModel.name)
      ..id = projectModel.id.toString()
      ..config = new YamlConfig(projectModel.config);
  }

  @override
  Future<String> saveProject(Project project) async {
    final projectModel = project.id == null
        ? (new BeaverProject()
          ..id = await _allocateProjectId()
          ..buildNumber = 0)
        : await _queryProjectModel(project.id);
    projectModel
      ..name = project.name
      ..config = project.config.toString();
    await db.commit(inserts: [projectModel]);
    return projectModel.id.toString();
  }

  @override
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result) async {
    final buildModel =
        await _queryBuildModel(projectId, buildNumber) ?? new BeaverBuild()
          ..number = buildNumber
          ..projectId = projectId;
    // TODO: consider serialization.
    buildModel
      ..triggerData = JSON.encode(result.triggerData)
      ..triggerType = result.triggerType
      ..triggerHeaders = JSON.encode(result.triggerHeaders)
      ..parsedTriggerEvent = result.parsedTriggerEvent
      ..parsedTriggerUrl = result.parsedTriggerUrl
      ..taskInstance = JSON.encode(result.taskInstance)
      ..taskInstanceStatus = result.taskInstanceStatus
      ..taskStatus = result.taskStatus
      ..taskConfigCloudType = result.taskConfigCloudType
      ..taskConfigCloudSettings = JSON.encode(result.taskConfigCloudSettings)
      ..taskLog = result.taskLog;
    await db.commit(inserts: [buildModel]);
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectId, int buildNumber) async {
    final buildModel = await _queryBuildModel(projectId, buildNumber);
    if (buildModel == null) {
      throw new NullThrownError();
    }

    final triggerHeaders =
        JSON.decode(buildModel.triggerHeaders) as Map<String, String>;
    final triggerData =
        JSON.decode(buildModel.triggerData) as Map<String, Object>;
    final taskInstance =
        JSON.decode(buildModel.taskInstance) as Map<String, Object>;
    final taskConfigCloudSettings =
        JSON.decode(buildModel.taskConfigCloudSettings) as Map<String, Object>;
    return new TriggerResult.fromGCloud(
        projectId,
        buildNumber,
        buildModel.triggerType,
        triggerHeaders,
        triggerData,
        buildModel.parsedTriggerEvent,
        buildModel.parsedTriggerUrl,
        taskInstance,
        buildModel.taskInstanceStatus,
        buildModel.taskStatus,
        buildModel.taskConfigCloudType,
        taskConfigCloudSettings,
        buildModel.taskLog);
  }

  @override
  Future<int> getBuildNumber(String projectId) async {
    return (await _queryProjectModel(projectId)).buildNumber;
  }

  @override
  Future<bool> setBuildNumber(String projectId, int buildNumber) async {
    final projectModel = await _queryProjectModel(projectId);
    projectModel.buildNumber = buildNumber;
    await db.commit(inserts: [projectModel]);
    return true;
  }

  @override
  Future<Null> initialize(Map<String, String> config) =>
      init(config['cloud_project_name'], config['zone']);
}
