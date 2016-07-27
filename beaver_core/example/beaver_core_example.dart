// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:beaver_core/beaver_core.dart';
import 'package:quiver_strings/strings.dart' as strings;

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
      new UnzipTask('download/dartsdk-linux-x64-release.zip', 'download'),
      new GitTask(['clone', 'git@github.com:fluidic/symbol.git']),
      new PubTask(['get'], processWorkingDir: 'symbol'),
      new PubTask(['run', 'test'], processWorkingDir: 'symbol')
    ];
    return Future.forEach(tasks, (task) => task.execute(context));
  }
}

main() async {
  Map<String, String> envVars = Platform.environment;
  final jsonCredentialsPath = envVars['SERVICE_ACCOUNT_CREDENTIALS_PATH'];
  if (strings.isEmpty(jsonCredentialsPath)) {
    print('SERVICE_ACCOUNT_CREDENTIALS_PATH is not set');
    return;
  }
  final jsonCredentials = await new File(jsonCredentialsPath).readAsString();
  Context context = await GCloudContext.create(jsonCredentials, 'my-project');
  Task task = new MyTask();
  TaskRunner runner = new TaskRunner(context, task);
  await runner.run();
}
