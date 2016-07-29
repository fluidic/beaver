// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;

import './beaver_core_base.dart';

class GCloudContextPart implements ContextPart {
  @override
  String get name => 'gcloud';

  Storage _storage;
  DatastoreDB _db;

  Storage get storage => _storage;
  DatastoreDB get db => _db;

  GCloudContextPart();

  Future<Null> setUp(Configuration conf) async {
    final jsonCredentialsPath =
        conf['gcloud']['service_account_credentials_path'];
    final projectName = conf['gcloud']['project_name'];
    final jsonCredentials = await new File(jsonCredentialsPath).readAsString();

    final credentials =
        new auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final scopes = []
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES);
    var client = await auth.clientViaServiceAccount(credentials, scopes);

    _db =
        new DatastoreDB(new datastore_impl.DatastoreImpl(client, projectName));
    _storage = new Storage(client, projectName);
  }

  Future<Null> tearDown() async {}
}
