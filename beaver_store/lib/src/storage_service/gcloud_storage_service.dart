import 'dart:async';
import 'dart:convert';

import 'package:beaver_gcloud/src/gcloud_mixin.dart';
import 'package:beaver_store/src/model/config.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:gcloud/datastore.dart' as datastore;

import '../model/project.dart';
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
    return query.run().first;
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
      ..triggerData = JSON.encode(result.trigger.data)
      ..triggerType = result.trigger.type
      ..triggerHeaders = JSON.encode(result.trigger.headers)
      ..triggerEvent = result.parsedTrigger.event
      ..triggerUrl = result.parsedTrigger.url
      ..taskInstance = JSON.encode(result.taskInstance)
      ..taskInstanceStatus =
          result.taskInstanceRunResult.status == TaskInstanceStatus.success
              ? "success"
              : "failure"
      ..taskStatus = result.taskInstanceRunResult.taskRunResult.status ==
              TaskStatus.Success
          ? "success"
          : "failure"
      ..taskConfig =
          result.taskInstanceRunResult.taskRunResult.config.toString()
      ..log = result.taskInstanceRunResult.taskRunResult.log.toString();
    await db.commit(inserts: [buildModel]);
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectId, int buildNumber) async {
    final buildModel = await _queryBuildModel(projectId, buildNumber);
    final project = await loadProject(projectId);
    final triggerData = JSON.decode(buildModel.triggerData);
    final trigger = new Trigger(buildModel.triggerType,
        JSON.decode(buildModel.triggerHeaders), triggerData);
    final parsedTrigger = new ParsedTrigger(
        new Event.fromString(buildModel.triggerEvent),
        buildModel.triggerUrl,
        triggerData);
    final taskInstance = JSON.decode(buildModel.taskInstance);
    final taskConfig = new YamlConfig(buildModel.taskConfig);
    final taskRunResult = new TaskRunResult(
        taskConfig,
        buildModel.taskStatus == "success"
            ? TaskStatus.Success
            : TaskStatus.Failure,
        buildModel.log);
    final taskInstanceRunResult = new TaskInstanceRunResult(
        buildModel.taskInstanceStatus == "success"
            ? TaskInstanceStatus.success
            : TaskInstanceStatus.failure,
        taskRunResult);
    return new TriggerResult(project, buildModel.number, trigger, parsedTrigger,
        taskInstance, taskInstanceRunResult);
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
}
