import 'dart:async';

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_default_credentials/googleapis_auth_default_credentials.dart';
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;
import 'package:googleapis/compute/v1.dart';
import 'package:http/http.dart' as http;

abstract class GCloudMixin {
  Storage _storage;
  DatastoreDB _db;
  ComputeApi _compute;

  Storage get storage => _storage;
  DatastoreDB get db => _db;
  ComputeApi get compute => _compute;

  Future<Null> init(Map<String, String> config) async {
    final project = config['project_name'];

    final client = new http.Client();
    final scopes = [ComputeApi.ComputeScope]
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES);
    AccessCredentials credentials =
        await obtainDefaultAccessCredentials(scopes, client);
    AuthClient authClient = authenticatedClient(client, credentials);

    _db =
        new DatastoreDB(new datastore_impl.DatastoreImpl(authClient, project));
    _storage = new Storage(authClient, project);
    _compute = new ComputeApi(authClient);
  }
}

