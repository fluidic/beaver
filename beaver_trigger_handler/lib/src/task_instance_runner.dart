import 'dart:async';
import 'dart:io';

import 'package:beaver_config_store/beaver_config_store.dart';
/// For [Task] registration.
import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';

class TaskInstanceRunner {
  final Context _context;
  final Project _project;
  final Map _taskInstance;

  TaskInstanceRunner(this._context, this._project, this._taskInstance);

  Future<TaskInstanceResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    Map<String, String> envVars = Platform.environment;
    final jsonCredentialsPath = envVars['SERVICE_ACCOUNT_CREDENTIALS_PATH'];
    if (jsonCredentialsPath == null || jsonCredentialsPath.isEmpty) {
      throw new Exception('SERVICE_ACCOUNT_CREDENTIALS_PATH is not set.');
    }
    final config = new Map.from(_project.config);
    config['service_account_credentials_path'] = jsonCredentialsPath;

    final result =
        await runBeaver(_taskInstance['name'], _taskInstance['args'], config);

    // FIXME: Set the self log.
    return new TaskInstanceResult(
        TaskInstanceStatus.success, _project, '', result);
  }
}

enum TaskInstanceStatus { success, failure }

class TaskInstanceResult {
  TaskInstanceStatus status;
  Project project;
  TaskRunResult taskRunResult;
  String log;

  TaskInstanceResult(this.status, this.project, this.log, this.taskRunResult);

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
      ..writeln('Project: ${project.name}')
      ..writeln('Build Number: ${project.buildNumber}')
      ..writeln('TaskInstanceResult -------')
      ..writeln('status: ${taskInstanceStatus}')
      ..writeln('project: ${project.toString()}')
      ..writeln('log: ${log}')
      ..writeln('TaskResult: ---')
      ..writeln('status: ${taskStatus}')
      ..writeln('config: ${taskRunResult.config.toString()}')
      ..writeln('log: ${taskRunResult.log}');
    return buffer.toString();
  }
}
