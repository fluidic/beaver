import 'dart:async';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;
import 'package:googleapis/compute/v1.dart';

abstract class GCloudMixin {
  Storage _storage;
  DatastoreDB _db;
  ComputeApi _compute;

  Storage get storage => _storage;
  DatastoreDB get db => _db;
  ComputeApi get compute => _compute;

  Future<Null> init(Map<String, String> config) async {
    final project = config['project_name'];
    final jsonCredentials = config['service_account_credentials'];
    final credentials =
        new auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final scopes = [ComputeApi.ComputeScope]
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES);
    var client = await auth.clientViaServiceAccount(credentials, scopes);

    _db = new DatastoreDB(new datastore_impl.DatastoreImpl(client, project));
    _storage = new Storage(client, project);
    _compute = new ComputeApi(client);
  }
}
