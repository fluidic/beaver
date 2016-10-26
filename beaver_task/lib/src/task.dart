import 'dart:async';

import './annotation.dart';
import './base.dart';

abstract class Task {
  const Task();

  Future<Object> execute(Context context);

  factory Task.fromFunc(ExecuteFunc func) => new _LambdaTask(func);
}

typedef Future<Object> ExecuteFunc(Context context);

@TaskClass('lambda')
class _LambdaTask implements Task {
  final ExecuteFunc _func;

  _LambdaTask(this._func);

  @override
  Future<Object> execute(Context context) => _func(context);
}
