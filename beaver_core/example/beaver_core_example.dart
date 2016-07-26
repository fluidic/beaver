// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:beaver_core/beaver_core.dart';

class MyTask implements Task {
  @override
  String get name => "my_task";

  @override
  Future<Object> execute(Context context) {
    List<Task> tasks = [
      new MkdirTask('download'),
      new GetTask(
          'https://storage.googleapis.com/dart-archive/channels/stable/release/1.17.1/sdk/dartsdk-linux-x64-release.zip',
          'download'),
      new UnzipTask('download/dartsdk-linux-x64-release.zip', 'download')
    ];
    return Future.forEach(tasks, (task) => task.execute(context));
  }
}

main() async {
  Context context = new DefaultContext();
  Task task = new MyTask();
  TaskRunner runner = new TaskRunner(context, task);
  await runner.run();
}
