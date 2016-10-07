import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_task/beaver_task_runner.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';

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
main(args, message) => runBeaver(
    'my_task',
    [],
    {
      'cloud_type': 'gcloud',
      'project_name': 'beaver-ci',
      'zone': 'us-central1-a'
    },
    newVM: true);
