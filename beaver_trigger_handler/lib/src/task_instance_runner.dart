import 'dart:async';

/// [GCloudStorageUploadTask] import.
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';
import 'package:beaver_store/beaver_store.dart' as beaver_store;
import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';

class TaskInstanceRunner {
  final Context _context;
  final beaver_store.Config _config;
  final ParsedTrigger _parsedTrigger;
  final Map _task;

  TaskInstanceRunner(
      this._context, this._config, this._parsedTrigger, Map taskInstance)
      : this._task = taskInstance['task'];

  Future<TaskInstanceRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final args = new List<String>();
    _task['args'].forEach((arg) {
      if (_parsedTrigger.isTriggerData(arg)) {
        args.add(_parsedTrigger.getTriggerData(arg));
      } else {
        args.add(arg);
      }
    });

    // FIXME: Change this logic after implementing setup(init) command.
    final config = new beaver_task.Config(_config['cloud_type'], {
      'project_name': _config['cloud_project_name'],
      'zone': _config['zone']
    });
    final result = await runBeaver(_task['name'], args, config);

    return new TaskInstanceRunResult(TaskInstanceStatus.success, result);
  }
}
