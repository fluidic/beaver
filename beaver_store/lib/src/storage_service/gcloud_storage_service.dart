import 'dart:async';
import 'dart:convert';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:beaver_trigger_handler/beaver_trigger.dart';
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

  Future<List<BeaverProject>> _queryProjectModels() async {
    final query = db.query(BeaverProject);
    return await query.run().toList();
  }

  Future<BeaverBuild> _queryBuildModel(
      String projectName, int buildNumber) async {
    final query = db.query(BeaverBuild)
      ..filter('projectName =', projectName)
      ..filter('number =', buildNumber);
    final result = await query.run().toList();
    return result.isEmpty ? null : result.first;
  }

  Future<List<BeaverBuild>> _queryBuildModels(String projectName) async {
    final query = db.query(BeaverBuild)..filter('projectName =', projectName);
    return await query.run().toList();
  }

  Project _convertProjectModelToProject(BeaverProject model) {
    final project = new Project(model.name);
    if (model.config != null) {
      project.config = new YamlConfig(UTF8.decode(model.config));
    }
    return project;
  }

  @override
  Future<Project> loadProject(String projectName) async {
    final projectModel = await _queryProjectModel(projectName);
    if (projectModel == null) {
      return null;
    }
    return _convertProjectModelToProject(projectModel);
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
    buildModel
      ..status = result.status
      ..trigger = UTF8.encode(JSON.encode(result.trigger.toJson()));
    if (result.parsedTrigger != null) {
      buildModel.parsedTrigger =
          UTF8.encode(JSON.encode(result.parsedTrigger.toJson()));
    }
    if (result.triggerConfig != null) {
      buildModel.triggerConfig = UTF8.encode(JSON.encode(result.triggerConfig));
    }
    if (result.taskRunResult != null) {
      buildModel.taskRunResult =
          UTF8.encode(JSON.encode(result.taskRunResult.toJson()));
    }
    await db.commit(inserts: [buildModel]);
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectName, int buildNumber) async {
    final buildModel = await _queryBuildModel(projectName, buildNumber);
    if (buildModel == null) {
      throw new NullThrownError();
    }

    final trigger = new Trigger.fromJson(UTF8.decode(buildModel.trigger));
    ParsedTrigger parsedTrigger;
    if (buildModel.parsedTrigger != null) {
      parsedTrigger =
          new ParsedTrigger.fromJson(UTF8.decode(buildModel.parsedTrigger));
    }
    Map<String, Object> triggerConfig;
    if (buildModel.triggerConfig != null) {
      triggerConfig = JSON.decode(UTF8.decode(buildModel.triggerConfig))
          as Map<String, Object>;
    }
    TaskRunResult taskRunResult;
    if (buildModel.taskRunResult != null) {
      taskRunResult =
          new TaskRunResult.fromJson(UTF8.decode(buildModel.taskRunResult));
    }
    return new TriggerResult(projectName, buildNumber, buildModel.status,
        trigger, parsedTrigger, triggerConfig, taskRunResult);
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

  @override
  Future<Iterable<Project>> listProjects() async {
    final projectModels = await _queryProjectModels();
    return projectModels
        .map((projectModel) => _convertProjectModelToProject(projectModel));
  }
}
