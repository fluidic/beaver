import 'dart:async';

import 'package:googleapis/compute/v1.dart';
import 'package:uuid/uuid.dart';

import './context.dart';

enum CreateVMStatus { Success, Error }

class CreateVMResult {
  // Status of CreateVM.
  final CreateVMStatus status;

  // Name of the instance resource.
  final String name;

  // The name of the zone for the instance.
  final String zone;

  CreateVMResult(this.status, this.name, this.zone);
}

Future<CreateVMResult> createVM(GCloudContext context, String zone) async {
  final name = 'beaver-worker-${new Uuid().v4()}';

  final instance = new Instance.fromJson({
    'name': name,
    'machineType':
        'projects/beaver-ci/zones/${zone}/machineTypes/n1-standard-1',
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
          "diskType": "projects/beaver-ci/zones/${zone}/diskTypes/pd-standard",
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
  });
  Operation op =
      await context.compute.instances.insert(instance, 'beaver-ci', zone);
  CreateVMStatus status =
      op.error == null ? CreateVMStatus.Success : CreateVMStatus.Error;
  return new CreateVMResult(status, name, zone);
}

enum DeleteVMStatus { Success, Error }

class DeleteVMResult {
  // Status of DeleteVM.
  final DeleteVMStatus status;

  DeleteVMResult(this.status);
}

Future<DeleteVMResult> deleteVM(
    GCloudContext context, String name, String zone) async {
  Operation op =
      await context.compute.instances.delete('beaver-ci', zone, name);
  DeleteVMStatus status =
      op.error == null ? DeleteVMStatus.Success : DeleteVMStatus.Error;
  return new DeleteVMResult(status);
}
