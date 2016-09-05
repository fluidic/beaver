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

    return new TaskInstanceResult.fromTaskRunResult(result);
  }
}

enum TaskInstanceStatus { success, failure }

// FIXME: This class is just wrapper of TaskRunResult. Do we need this?
class TaskInstanceResult {
  TaskInstanceStatus status;
  String log;

  TaskInstanceResult(this.status, this.log);

  TaskInstanceResult.fromTaskRunResult(TaskRunResult result) {
    status = result.status == TaskStatus.Success
        ? TaskInstanceStatus.success
        : TaskInstanceStatus.failure;

    StringBuffer b = new StringBuffer();
    b..write(result.config.toString())..write(result.status)..write(result.log);
    log = b.toString();
  }

  TaskInstanceResult.fromProcessResult(ProcessResult result) {
    status = TaskInstanceStatus.success;
    if (result.exitCode != 0) {
      status = TaskInstanceStatus.failure;
    }

    StringBuffer buffer = new StringBuffer();
    buffer
      ..write('stdout: ')
      ..write(result.stdout)
      ..write(', stderr: ')
      ..write(result.stderr);
    log = buffer.toString();
  }

  @override
  String toString() {
    var statusStr = 'success';
    if (status != TaskInstanceStatus.success) {
      statusStr = 'failure';
    }

    final buffer = new StringBuffer();
    buffer
      ..writeln('TaskInstanceResult: ')
      ..writeln('status: ${statusStr}')
      ..writeln('logs: ${log}');
    return buffer.toString();
  }
}
