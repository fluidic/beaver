import 'dart:async';

import './base.dart';
import './task/git_task.dart';

class TaskRunner {
  final Context context;
  final Task task;

  TaskRunner(this.context, /* Task|ExecuteFunc */ task)
      : this.task = task is Task ? task : new Task.fromFunc(task);

  Future<Null> _cloneRepo() async {
    // FIXME: Support the repository types other than git.
    final repo = context.configuration['repository']['location'];
    await new GitTask(['clone', repo]).execute(context);
  }

  Future<TaskRunResult> run() async {
    await _cloneRepo();

    var status = TaskStatus.Success;
    final logger = context.logger;
    try {
      await task.execute(context);
    } on TaskException catch (e) {
      logger.error(e);
      status = TaskStatus.Failure;
    } catch (e) {
      logger.error(e);
      status = TaskStatus.Failure;
    }

    return new TaskRunResult._internal(context.configuration, status, logger.toString());
  }
}

enum TaskStatus { Success, Failure }

String taskStatusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.Success:
      return 'success';
    case TaskStatus.Failure:
      return 'failure';
  }
}

class TaskRunResult {
  final Configuration configuration;

  final TaskStatus status;

  final String log;

  TaskRunResult._internal(this.configuration, this.status, this.log);
}

