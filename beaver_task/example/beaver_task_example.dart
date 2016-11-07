import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:beaver_task/beaver_task_runner.dart';

Map myTask = {
  'name': 'seq',
  'args': [
    {
      'name': 'mkdir',
      'args': ['download']
    },
    {
      'name': 'download',
      'args': [
        'https://raw.githubusercontent.com/fluidic/beaver/master/README.md',
        'download'
      ]
    }
  ]
};

Future<Null> main(args) async {
  await runBeaver(
      myTask,
      new Config(
          'gcloud', {'project_name': 'beaver-ci', 'zone': 'us-central1-a'}, {}),
      newVM: false);
}
