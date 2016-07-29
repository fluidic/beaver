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

Future runBeaver(ExecuteFunc func) async {
  Configuration conf = new YamlConfiguration.fromFile('beaver.yaml');
  // FIXME: Don't hardcode parts and logger.
  final parts = [new GCloudContextPart()];
  final logger = new ConsoleLogger();
  Context context =
      await DefaultContext.create(conf, parts: parts, logger: logger);
  TaskRunner runner = new TaskRunner(context, func);
  TaskRunResult result = await runner.run();
  // FIXME: Don't hardcode reporter.
  JsonReporter reporter = new JsonReporter(result);
  print(reporter.toJson());
}

