import 'dart:async';
import 'dart:convert';

/// [PubTask] import.
import 'package:beaver_dart_task/beaver_dart_task.dart';
/// [GCloudStorageUploadTask] import.
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';
import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';
import './cloud_info.dart';

class TaskInstanceRunner {
  final Context _context;
  final Trigger _trigger;
  final ParsedTrigger _parsedTrigger;
  final List<Map<String, Object>> _tasks;
  final int _buildNumber;
  final CloudInfo _cloudInfo;
  final bool _newVM;

  TaskInstanceRunner(this._context, this._trigger, this._parsedTrigger,
      this._tasks, this._buildNumber, this._cloudInfo, this._newVM);

  Future<TaskInstanceRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final jsonTask = _createJson(_tasks, _parsedTrigger);
    _context.logger.fine('Task: $jsonTask');

    final config = new beaver_task.Config(_cloudInfo.type, {
      'project_name': _cloudInfo.projectName,
      // FIXME: Don't hardcode
      'zone': _cloudInfo.region + '-a'
    }, {
      'request_url': _cloudInfo.baseUrl.toString(),
      'trigger_name': _trigger.name,
      'project_name': _trigger.projectName,
      'build_number': _buildNumber.toString()
    });
    final result = await runBeaver(jsonTask, config, newVM: _newVM);

    return new TaskInstanceRunResult(TaskInstanceStatus.success, result);
  }
}

String _getArg(String arg, ParsedTrigger parsedTrigger) {
  if (parsedTrigger.isTriggerData(arg)) {
    return parsedTrigger.getTriggerData(arg);
  }
  return arg;
}

Map<String, Object> _createJsonForTask(
    Map<String, Object> taskInstance, ParsedTrigger parsedTrigger) {
  assert(taskInstance.isNotEmpty);

  final args = taskInstance['args'] as List;
  var resultArgs = [];

  for (final arg in args) {
    if (arg is String) {
      resultArgs.add(_getArg(arg, parsedTrigger));
    } else if (arg is Map) {
      resultArgs
          .add(_createJsonForTask(arg as Map<String, Object>, parsedTrigger));
    } else {
      throw new Exception('Task arg should be String or Map.');
    }
  }
  return {'name': taskInstance['name'], 'args': resultArgs};
}

String _createJson(
    List<Map<String, Object>> taskInstances, ParsedTrigger parsedTrigger) {
  final taskList = [];
  taskInstances.forEach((taskInstance) {
    taskList.add(_createJsonForTask(taskInstance, parsedTrigger));
  });

  if (taskList.length == 1) {
    return JSON.encode(taskList[0]);
  } else {
    return JSON.encode({'name': 'seq', 'args': taskList});
  }
}
