// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

class TaskRunner {
  final Context context;
  final Task task;

  TaskRunner(this.context, /* Task|ExecuteFunc */ task)
      : this.task = task is Task ? task : new Task.fromFunc(task);

  Future<TaskRunResult> run() async {
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

    return new TaskRunResult._internal(status, logger.toString());
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
  final TaskStatus status;

  final String log;

  TaskRunResult._internal(this.status, this.log);
}

