import 'dart:async';

import './base.dart';

class _ParallelTask implements Task {
  @override
  String get name => 'parallel_task';

  final Iterable<Task> _tasks;

  _ParallelTask(this._tasks);

  @override
  Future<List> execute(Context context) => Future
      .wait(_tasks.map((task) => task.execute(context)), eagerError: true);
}

class _SequentialTask implements Task {
  @override
  String get name => 'sequential_task';

  final Iterable<Task> _tasks;

  _SequentialTask(this._tasks);

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
