import 'dart:async';
import 'dart:io';

import 'package:beaver_core/beaver_core.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;

@ContextPartClass('gcloud')
class GCloudContextPart extends ContextPart {
  Storage _storage;
  DatastoreDB _db;

  Storage get storage => _storage;
  DatastoreDB get db => _db;

  GCloudContextPart();

  Future<Null> setUp(Config config) async {
    final jsonCredentialsPath =
        config['gcloud']['service_account_credentials_path'];
    final projectName = config['gcloud']['project_name'];
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
