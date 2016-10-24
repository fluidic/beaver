import 'dart:async';

import './annotation.dart';
import './base.dart';

@TaskClass('par')
class _ParallelTask implements Task {
  final Iterable<Task> _tasks;

  _ParallelTask(this._tasks);

  _ParallelTask.fromArgs(this._tasks);

  @override
  Future<List> execute(Context context) => Future
      .wait(_tasks.map((task) => task.execute(context)), eagerError: true);
}

@TaskClass('seq')
class _SequentialTask implements Task {
  final Iterable<Task> _tasks;

  _SequentialTask(this._tasks);

  _SequentialTask.fromArgs(this._tasks);

  @override
  Future<Object> execute(Context context) async {
    var result;
    for (final task in _tasks) {
      result = await task.execute(context);
    }
    return result;
  }
}

Task par(Iterable<Task> tasks) => new _ParallelTask(tasks);
Task seq(Iterable<Task> tasks) => new _SequentialTask(tasks);
