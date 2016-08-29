import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart' as beaver_core;

import './base.dart';

class TaskInstanceRunner {
  final Context _context;
  final Map _taskInstance;

  TaskInstanceRunner(this._context, this._taskInstance);

  Future<TaskInstanceResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    // FIXME: Get the result and pass it to TaskInstanceResult.
    // FIXME: Add the logic to run task on the other vm.
    // FIXME: TriggerHandler has the config as Yaml already. Make runBeaver
    // can take it.
    beaver_core.runBeaver(_taskInstance['name'], _taskInstance['args']);

    return new TaskInstanceResult(TaskInstanceStatus.success, '');
  }
}

enum TaskInstanceStatus { success, failure }

class TaskInstanceResult {
  TaskInstanceStatus status;
  String log;

  TaskInstanceResult(this.status, this.log);

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
      ..writeln('JobRunResult: ')
      ..writeln('status: ${statusStr}')
      ..writeln('logs: ${log}');
    return buffer.toString();
  }
}

class MemoryLogger extends beaver_core.Logger {
  final StringBuffer _buffer = new StringBuffer();

  MemoryLogger();

  @override
  void log(beaver_core.LogLevel logLevel, message) {
    _buffer.writeln('${logLevel}: ${message}');
  }

  @override
  String toString() => _buffer.toString();
}
