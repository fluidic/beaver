import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart' as beaver_core;

import './base.dart';
import './utils/reflection.dart';

class TaskInstanceRunner {
  final Context _context;
  final Map _taskInstance;

  TaskInstanceRunner(this._context, this._taskInstance);

  Future<TaskInstanceResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    // FIXME: Use runBeaver of beaver core.
    final taskClassMap = loadClassMapByAnnotation(beaver_core.TaskClass);
    final config = null;
    final logger = new MemoryLogger();
    final context = new beaver_core.DefaultContext(config, logger, {});

    final args = _taskInstance['args']
        ? _taskInstance['args'].toList(growable: false)
        : [];
    final task = newInstance(taskClassMap[_taskInstance['name']], args);

    var status = TaskInstanceStatus.success;
    try {
      await task.execute(context);
    } catch (e) {
      logger.error(e);
      status = TaskInstanceStatus.failure;
    }

    return new TaskInstanceResult(status, logger.toString());
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
