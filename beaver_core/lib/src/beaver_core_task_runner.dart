// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';

class TaskRunner {
  final Context context;
  final Task task;

  TaskRunner(this.context, this.task);

  Future<Null> run() async {
    try {
      await task.execute(context);
    } on TaskException catch (e) {
      context.logger.error(e);
    } catch (e) {
      context.logger.error(e);
    }
  }
}

