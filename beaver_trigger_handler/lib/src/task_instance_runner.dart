import 'dart:async';
import 'dart:convert';

/// [PubTask] import.
import 'package:beaver_dart_task/beaver_dart_task.dart';
/// [DockerTask] import
import 'package:beaver_docker_task/beaver_docker_task.dart';
/// [GCloudStorageUploadTask] import.
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';
import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';
import './status.dart';

class TaskInstanceRunner {
  final Context _context;
  final List<Map<String, Object>> _tasks;
  final bool _newVM;

  TaskInstanceRunner(this._context, this._tasks, this._newVM);

  Future<TaskRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final jsonTask = _createJson(_context, _tasks, _context.parsedTrigger);
    _context.logger.fine('Task: $jsonTask');

    final config = new beaver_task.Config(_context.cloudInfo.type, {
      'project_name': _context.cloudInfo.projectName,
      // FIXME: Don't hardcode
      'zone': _context.cloudInfo.region + '-a'
    }, {
      'request_url': _context.cloudInfo.baseUrl.toString(),
      'trigger_name': _context.trigger.name,
      'project_name': _context.trigger.projectName,
      'build_number': _context.buildNumber.toString(),
      'site_id': _context.cloudInfo.siteId
    });
    try {
      return await runBeaver(jsonTask, config, newVM: _newVM);
    } catch (e) {
      setStatus(_context, 600, value: [e.toString()]);
      throw e;
    }
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

String _createJson(Context context, List<Map<String, Object>> taskInstances,
    ParsedTrigger parsedTrigger) {
  try {
    final taskList = [];
    taskInstances.forEach((taskInstance) {
      taskList.add(_createJsonForTask(taskInstance, parsedTrigger));
    });

    if (taskList.length == 1) {
      return JSON.encode(taskList[0]);
    } else {
      return JSON.encode({'name': 'seq', 'args': taskList});
    }
  } catch (e) {
    setStatus(context, 500, value: [e.toString()]);
    throw e;
  }
}
