// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';
import './beaver_core_configuration.dart';
import './beaver_core_context.dart';
import './beaver_core_gcloud_context_part.dart';
import './beaver_core_logger.dart';
import './beaver_core_reporter.dart';
import './beaver_core_task_runner.dart';

Future runBeaver(obj) async {
  Configuration conf = new YamlConfiguration.fromFile('beaver.yaml');
  // FIXME: Don't hardcode parts and logger.
  final parts = [new GCloudContextPart()];
  final logger = new ConsoleLogger();
  Context context =
      await DefaultContext.create(conf, parts: parts, logger: logger);

  var task;
  if (obj is Function || obj is Task) {
    task = obj;
  } else if (obj is Iterable<Task>) {
    task = (Context context) => Future.forEach(obj, (t) => t.execute(context));
  } else {
    throw new ArgumentError(
        'argument must be either ExecuteFunc, Task or Iterable<Task>');
  }

  TaskRunner runner = new TaskRunner(context, task);
  TaskRunResult result = await runner.run();
  // FIXME: Don't hardcode reporter.
  JsonReporter reporter = new JsonReporter(result);
  print(reporter.toJson());
}
