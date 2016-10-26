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
    Map<String, ClassMirror> taskClassMap = queryNameClassMapByAnnotation(TaskClass);
    return _createTaskFromJson(json, taskClassMap);
  }
}

Task _createTaskFromJson(json, Map<String, ClassMirror> taskClassMap) {
  if (json is String) {
    json = JSON.decode(json);
  }
  if (json is! Map) {
    throw new ArgumentError('json must be a Map or a String encoding a Map.');
  }

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
class _LambdaTask implements Task {
  final ExecuteFunc _func;

  _LambdaTask(this._func);

  @override
  Future<Object> execute(Context context) => _func(context);
}
