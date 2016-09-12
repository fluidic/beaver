import 'dart:async';

import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';

class TaskInstanceRunner {
  final Context _context;
  final beaver_task.Config _config;
  final Map _taskInstance;

  TaskInstanceRunner(this._context, this._config, Map taskInstance)
      : this._taskInstance = taskInstance['task'];

  Future<TaskInstanceRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final result =
        await runBeaver(_taskInstance['name'], _taskInstance['args'], _config);

    return new TaskInstanceRunResult(TaskInstanceStatus.success, result);
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
      ..writeln('TaskInstanceResult -------')
      ..writeln('status: ${taskInstanceStatus}')
      ..writeln('TaskResult: ---')
      ..writeln('status: ${taskStatus}')
      ..writeln('config: ${taskRunResult.config.toString()}')
      ..writeln('log: ${taskRunResult.log}');
    return buffer.toString();
  }
}
