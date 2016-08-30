import 'dart:async';

import 'package:beaver_core/beaver_core.dart';
import 'package:beaver_core/beaver_core_runner.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';

@TaskClass('my_task')
class MyTask implements Task {
  MyTask.fromArgs(List<String> args);

  @override
  Future<Object> execute(Context context) => seq([
        new InstallDartSdkTask(withContentShell: true, withDartium: true),
        new PubTask(['get'], processWorkingDir: 'symbol'),
        new PubTask(['run', 'test'], processWorkingDir: 'symbol')
      ]).execute(context);
}

// FIXME: Get the task name from the message
main(args, message) => runBeaver('my_task', []);
