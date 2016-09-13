import 'dart:async';

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

    final result = await runBeaver(_task['name'], args, _config);

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
