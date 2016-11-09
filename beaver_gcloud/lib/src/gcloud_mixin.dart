import 'dart:async';

import 'package:beaver_utils/beaver_utils.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth_default_credentials/googleapis_auth_default_credentials.dart';
import 'package:gcloud/db.dart';
import 'package:gcloud/storage.dart';
import 'package:gcloud/src/datastore_impl.dart' as datastore_impl;
import 'package:googleapis/compute/v1.dart';
import 'package:http/http.dart' as http;

enum CreateVMStatus { success, failToAddSshKey, error }

class CreateVMResult {
  // Status of CreateVM.
  final CreateVMStatus status;

  // The name of the zone for the instance.
  final String zone;

  // Name of the instance resource.
  final String name;

  // List of network IP addresses.
  final List<String> networkIPs;

  /// The external IP address.
  final String externalIP;

  CreateVMResult(
      this.status, this.name, this.zone, this.networkIPs, this.externalIP);
}

enum DeleteVMStatus { success, error }

class DeleteVMResult {
  // Status of DeleteVM.
  final DeleteVMStatus status;

  DeleteVMResult(this.status);
}

abstract class GCloud {
  Storage get storage;
  DatastoreDB get db;
  ComputeApi get compute;

  Future<CreateVMResult> createVM();
  Future<DeleteVMResult> deleteVM(String instanceName);
}

abstract class GCloudMixin implements GCloud {
  Storage _storage;
  DatastoreDB _db;
  ComputeApi _compute;
  String _project;
  String _zone;

  String get project => _project;
  String get region => _zone.replaceAll(new RegExp(r'-[a-z]+$'), '');

  @override
  Storage get storage => _storage;

  @override
  DatastoreDB get db => _db;

  @override
  ComputeApi get compute => _compute;

  Future<Null> init(String project, String zone) async {
    final client = new http.Client();
    List<String> scopes = []
      ..add(ComputeApi.ComputeScope)
      ..addAll(datastore_impl.DatastoreImpl.SCOPES)
      ..addAll(Storage.SCOPES);
    AccessCredentials credentials =
        await obtainDefaultAccessCredentials(scopes, client);
    AuthClient authClient = authenticatedClient(client, credentials);

    _db =
        new DatastoreDB(new datastore_impl.DatastoreImpl(authClient, project));
    _storage = new Storage(authClient, project);
    _compute = new ComputeApi(authClient);
    _project = project;
    _zone = zone;
  }

  @override
  Future<CreateVMResult> createVM({String sshPublicKey}) async {
    final name = 'beaver-worker-${uniqueName()}';

    var instance = new Instance.fromJson({
      'name': name,
      'machineType':
          'projects/beaver-ci/zones/$_zone/machineTypes/n1-standard-1',
      "disks": [
        {
          "type": "PERSISTENT",
          "boot": true,
          "mode": "READ_WRITE",
          "autoDelete": true,
          "deviceName": name,
          "initializeParams": {
            "sourceImage":
                "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-8-jessie-v20160803",
            "diskType": "projects/beaver-ci/zones/$_zone/diskTypes/pd-standard",
            "diskSizeGb": "10"
          }
        }
      ],
      "networkInterfaces": [
        {
          "network": "projects/beaver-ci/global/networks/default",
          "subnetwork":
              "projects/beaver-ci/regions/us-central1/subnetworks/default",
          "accessConfigs": [
            {"name": "External NAT", "type": "ONE_TO_ONE_NAT"}
          ]
        }
      ],
      "serviceAccounts": [
        {
          "email": "default",
          "scopes": ["https://www.googleapis.com/auth/cloud-platform"]
        }
      ],
    });
    Operation op = await compute.instances.insert(instance, _project, _zone);
    CreateVMStatus status =
        op.error == null ? CreateVMStatus.success : CreateVMStatus.error;

    // IP addresses are not available in PROVISIONING status.
    // FIXME: Avoid polling if possible.
    do {
      await new Future.delayed(new Duration(seconds: 1));
      instance = await compute.instances.get(_project, _zone, name);
    } while (instance.status == 'PROVISIONING');

    List<String> networkIPs =
        instance.networkInterfaces.map((ni) => ni.networkIP);
    String natIP = instance.networkInterfaces.first.accessConfigs.first.natIP;

    if (sshPublicKey != null) {
      MetadataItems item = new MetadataItems()
        ..key = 'ssh-keys'
        ..value = sshPublicKey;
      instance.metadata.items = [item];
      op = await compute.instances
          .setMetadata(instance.metadata, _project, _zone, name);
      if (op.error != null) {
        status = CreateVMStatus.failToAddSshKey;
      }
    }

    return new CreateVMResult(status, name, _zone, networkIPs, natIP);
  }

  @override
  Future<DeleteVMResult> deleteVM(String instanceName) async {
    Operation op =
        await compute.instances.delete(_project, _zone, instanceName);
    DeleteVMStatus status =
        op.error == null ? DeleteVMStatus.success : DeleteVMStatus.error;
    return new DeleteVMResult(status);
  }
}

abstract class GCloudBase extends Object with GCloudMixin {}
