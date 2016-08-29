import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart' as beaver_core;
import 'package:beaver_store/beaver_store.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './utils/reflection.dart';

class TaskInstanceRunner {
  final Context _context;
  final String _event;
  final Project _project;

  TaskInstanceRunner(this._context, this._event, this._project);

  Future<TaskInstanceResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final YamlList triggers = this._project.config['triggers'];
    final taskInstance = triggers
        .firstWhere((trigger) => trigger['events'].contains(_event))['task'];
    final result = await _run(taskInstance);

    return result;
  }

  static Future<TaskInstanceResult> _run(YamlMap task) async {
    // FIXME: Use runBeaver of beaver core.
    final taskClassMap = loadClassMapByAnnotation(beaver_core.TaskClass);
    final config = null;
    final logger = new MemoryLogger();
    final context = new beaver_core.DefaultContext(config, logger, {});

    final args =
        task['args'] ? (task['args'] as YamlList).toList(growable: false) : [];
    final taskInstance = newInstance(taskClassMap[task['name']], args);

    var status = TaskInstanceStatus.success;
    try {
      await taskInstance.execute(context);
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
