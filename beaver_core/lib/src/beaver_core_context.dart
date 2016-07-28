// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import './beaver_core_base.dart';
import './beaver_core_logger.dart';

class DefaultContext implements Context {
  final Configuration _conf;
  final Logger _logger;
  final Map<String, ContextPart> _partMap;

  @override
  Configuration get configuration => _conf;

  @override
  Logger get logger => _logger;

  @override
  ContextPart getPart(String name) => _partMap[name];

  static Future<Context> create(Configuration conf,
      {Logger logger: const NoneLogger(),
      Iterable<ContextPart> parts: const []}) async {
    final memoryLogger = new MemoryLogger(logger);

    Map<String, ContextPart> partMap = {};
    final futures = parts.map((ContextPart part) {
      partMap[part.name] = part;
      return part.setUp();
    });
    await Future.wait(futures);

    return new DefaultContext._internal(conf, memoryLogger, partMap);
  }

  DefaultContext._internal(this._conf, this._logger, this._partMap);
}
