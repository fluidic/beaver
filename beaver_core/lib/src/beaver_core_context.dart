// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import './beaver_core_base.dart';
import './beaver_core_logger.dart';

class DefaultContext implements Context {
  final Configuration _conf;
  final Logger _logger;

  @override
  Configuration get configuration => _conf;

  @override
  Logger get logger => _logger;

  DefaultContext()
      : _conf = new Configuration(),
        _logger = new SimpleLogger();
}
