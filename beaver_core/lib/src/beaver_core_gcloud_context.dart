// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;

import './beaver_core_base.dart';
import './beaver_core_logger.dart';

class GCloudContext implements Context {
  final Configuration _conf;
  final Logger _logger;
  final Storage _storage;
  final DatastoreDB _db;

  @override
  Configuration get configuration => _conf;

  @override
  Logger get logger => _logger;

  Storage get storage => _storage;

  DatastoreDB get db => _db;

  static Future<GCloudContext> create(
      String jsonCredentials, String projectName) async {
    final conf = new Configuration();
    final logger = new SimpleLogger();

    final credentials =
        new auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final scopes = []
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES);
    var client = await auth.clientViaServiceAccount(credentials, scopes);

    final db =
        new DatastoreDB(new datastore_impl.DatastoreImpl(client, projectName));
    final storage = new Storage(client, projectName);
    return new GCloudContext._internal(conf, logger, storage, db);
  }

  GCloudContext._internal(this._conf, this._logger, this._storage, this._db);
}
