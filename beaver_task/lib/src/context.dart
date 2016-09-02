import 'dart:async';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;

import './base.dart';

class GCloudContext implements Context {
  Storage _storage;
  DatastoreDB _db;

  final Config _config;
  final Logger _logger;
  final Map<String, ContextPart> _partMap;

  Storage get storage => _storage;

  DatastoreDB get db => _db;

  @override
  Config get config => _config;

  @override
  Logger get logger => _logger;

  @override
  ContextPart getPart(String name) => _partMap[name];

  GCloudContext(this._config, this._logger, this._partMap);

  Future<Null> setUp() async {
    final jsonCredentialsPath = _config['service_account_credentials_path'];
    final projectName = _config['project_name'];
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
}
