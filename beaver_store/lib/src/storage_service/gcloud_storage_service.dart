import 'dart:async';
import 'dart:convert';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:gcloud/datastore.dart' as datastore;
import 'package:gcloud/db.dart';

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

  Future<BeaverProject> _queryProjectModel(String projectName) async {
    final query = db.query(BeaverProject)..filter('name =', projectName);
    final result = await query.run().toList();
    return result.isEmpty ? null : result.first;
  }

  Future<BeaverBuild> _queryBuildModel(
      String projectName, int buildNumber) async {
    final query = db.query(BeaverBuild)
      ..filter('projectName =', projectName)
      ..filter('number =', buildNumber);
    final result = await query.run().toList();
    return result.isEmpty ? null : result.first;
  }

  Future<List<BeaverBuild>> _queryBuildModels(
      String projectName) async {
    final query = db.query(BeaverBuild)
      ..filter('projectName =', projectName);
    return await query.run().toList();
  }

  @override
  Future<Project> loadProject(String projectName) async {
    final projectModel = await _queryProjectModel(projectName);
    if (projectModel == null) {
      return null;
    }
    final project = new Project(projectModel.name);
    if (projectModel.config != null) {
      project.config = new YamlConfig(UTF8.decode(projectModel.config));
    }
    return project;
  }

  @override
  Future<Null> saveProject(Project project) async {
    var projectModel = await _queryProjectModel(project.name);
    if (projectModel == null) {
      projectModel = new BeaverProject()
        ..id = await _allocateProjectId()
        ..buildNumber = 0;
    }
    projectModel
      ..name = project.name
      ..config = UTF8.encode(project.config.toString());
    await db.commit(inserts: [projectModel]);
  }

  @override
  Future<bool> saveResult(
      String projectName, int buildNumber, TriggerResult result) async {
    final buildModel =
        await _queryBuildModel(projectName, buildNumber) ?? new BeaverBuild()
          ..number = buildNumber
          ..projectName = projectName;
    // TODO: consider serialization.
    buildModel
      ..triggerData = UTF8.encode(JSON.encode(result.triggerData))
      ..triggerType = result.triggerType
      ..triggerHeaders = JSON.encode(result.triggerHeaders)
      ..parsedTriggerEvent = result.parsedTriggerEvent
      ..parsedTriggerUrl = result.parsedTriggerUrl
      ..taskInstance = JSON.encode(result.taskInstance)
      ..taskInstanceStatus = result.taskInstanceStatus
      ..taskStatus = result.taskStatus
      ..taskConfigCloudType = result.taskConfigCloudType
      ..taskConfigCloudSettings = JSON.encode(result.taskConfigCloudSettings)
      ..taskLog = UTF8.encode(result.taskLog);
    await db.commit(inserts: [buildModel]);
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectName, int buildNumber) async {
    final buildModel = await _queryBuildModel(projectName, buildNumber);
    if (buildModel == null) {
      throw new NullThrownError();
    }

    final triggerHeaders =
        JSON.decode(buildModel.triggerHeaders) as Map<String, String>;
    final triggerData =
        JSON.decode(UTF8.decode(buildModel.triggerData)) as Map<String, Object>;
    final taskInstance =
        JSON.decode(buildModel.taskInstance) as Map<String, Object>;
    final taskConfigCloudSettings =
        JSON.decode(buildModel.taskConfigCloudSettings) as Map<String, Object>;
    return new TriggerResult.fromGCloud(
        projectName,
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
        UTF8.decode(buildModel.taskLog));
  }

  @override
  Future<int> getBuildNumber(String projectName) async {
    return (await _queryProjectModel(projectName)).buildNumber;
  }

  @override
  Future<bool> setBuildNumber(String projectName, int buildNumber) async {
    final projectModel = await _queryProjectModel(projectName);
    projectModel.buildNumber = buildNumber;
    await db.commit(inserts: [projectModel]);
    return true;
  }

  @override
  Future<Null> initialize(Map<String, String> config) =>
      init(config['cloud_project_name'], config['zone']);

  @override
  Future<Null> removeProject(String projectName) async {
    final projectModel = await _queryProjectModel(projectName);
    await db.commit(deletes: [projectModel.key]);
  }

  @override
  Future<Null> removeResult(String projectName) async {
    final buildModels = await _queryBuildModels(projectName);
    final buildModelKeys = new List<Key>();
    buildModels.forEach((buildModel) => buildModelKeys.add(buildModel.key));
    await db.commit(deletes: buildModelKeys);
  }
}
