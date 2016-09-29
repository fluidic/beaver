import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';
import './trigger_parser.dart';

class TaskInstanceRunner {
  final Context _context;
  final beaver_task.Config _config;
  final ParsedTrigger _parsedTrigger;
  final Map _task;

  TaskInstanceRunner(
      this._context, this._config, this._parsedTrigger, Map taskInstance)
      : this._task = taskInstance['task'];

  Future<TaskInstanceRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final args = [];
    _task['args'].forEach((arg) {
      if (_parsedTrigger.isTriggerData(arg)) {
        args.add(_parsedTrigger.getTriggerData(arg));
      } else {
        args.add(arg);
      }
    });

    // FIXME: Change this logic after implementing setup(init) command.
    // FIXME: Passing this to runBeaver causes type error if check mode is on.
    final config = {
      'cloud_type': _config['cloud_type'],
      'service_account_credentials': await _serviceAccountCredentials(
          _config['service_account_credentials_path']),
      'project_name': _config['cloud_project_name'],
      'zone': _config['zone']
    };

    final result = await runBeaver(_task['name'], args, config);
    result.config.clear();

    return new TaskInstanceRunResult(TaskInstanceStatus.success, result);
  }

  Future<Map<String, String>> _serviceAccountCredentials(String path) async {
    return JSON.decode(await new File(path).readAsString());
  }
}

enum TaskInstanceStatus { success, failure }

class TaskInstanceRunResult {
  final TaskInstanceStatus status;
  final TaskRunResult taskRunResult;

  TaskInstanceRunResult(this.status, this.taskRunResult);

  @override
  String toString() {
    var taskInstanceStatus = 'success';
    if (status != TaskInstanceStatus.success) {
      taskInstanceStatus = 'failure';
    }

    var taskStatus = 'success';
    if (taskRunResult.status != TaskStatus.Success) {
      taskStatus = 'failure';
    }

    final buffer = new StringBuffer();
    buffer
      ..writeln('status: ${taskInstanceStatus}')
      ..writeln('TaskRunResult')
      ..writeln('status: ${taskStatus}')
      ..writeln('config: ${taskRunResult.config.toString()}')
      ..writeln('log: ${taskRunResult.log}');
    return buffer.toString();
  }
}
