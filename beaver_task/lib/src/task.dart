import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

import 'package:beaver_utils/beaver_utils.dart';

import './annotation.dart';
import './base.dart';

abstract class Task {
  const Task();

  Future<Object> execute(Context context);

  factory Task.fromFunc(ExecuteFunc func) => new _LambdaTask(func);

  factory Task.fromJson(json) {
    if (json is String) {
      json = JSON.decode(json);
    }
    if (json is! Map) {
      throw new ArgumentError('json must be a Map or a String encoding a Map.');
    }

    Map<String, ClassMirror> taskClassMap =
        queryNameClassMapByAnnotation(TaskClass);
    return _createTaskFromJson(json, taskClassMap);
  }

  /// Executes the task [t] after this task.
  Task operator >>(Task t) => seq([this, t]);

  /// Executes the task [t] in parallel with this task.
  Task operator |(Task t) => par([this, t]);
}

Task _createTaskFromJson(json, Map<String, ClassMirror> taskClassMap) {
  final name = json['name'];
  final args = [];
  for (final arg in json['args']) {
    if (arg is String) {
      args.add(arg);
    } else if (arg is Map) {
      args.add(_createTaskFromJson(arg, taskClassMap));
    } else {
      throw new ArgumentError('arg must be a Map or a String');
    }
  }

  return newInstance('fromArgs', taskClassMap[name], [args]);
}

typedef Future<Object> ExecuteFunc(Context context);

@TaskClass('lambda')
class _LambdaTask extends Task {
  final ExecuteFunc _func;

  _LambdaTask(this._func);

  @override
  Future<Object> execute(Context context) => _func(context);
}

@TaskClass('par')
class _ParallelTask extends Task {
  final Iterable<Task> _tasks;

  _ParallelTask(this._tasks);

  _ParallelTask.fromArgs(this._tasks);

  @override
  Future<List> execute(Context context) => Future
      .wait(_tasks.map((task) => task.execute(context)), eagerError: true);
}

@TaskClass('seq')
class _SequentialTask extends Task {
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
