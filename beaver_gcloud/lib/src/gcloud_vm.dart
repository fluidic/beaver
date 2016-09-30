import 'dart:async';

import 'package:googleapis/compute/v1.dart';
import 'package:unique/unique.dart';

import './gcloud_mixin.dart';

enum CreateVMStatus { Success, Error }

class CreateVMResult {
  // Status of CreateVM.
  final CreateVMStatus status;

  // The name of the zone for the instance.
  final String zone;

  // Name of the instance resource.
  final String name;

  // List of network IP addresses.
  final List<String> networkIPs;

  CreateVMResult(this.status, this.name, this.zone, this.networkIPs);
}

Future<CreateVMResult> createVM(
    GCloudMixin context, String project, String zone) async {
  final name = 'beaver-worker-${uniqueName()}';

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
      await context.compute.instances.insert(instance, project, zone);
  CreateVMStatus status =
      op.error == null ? CreateVMStatus.Success : CreateVMStatus.Error;

  // IP addresses are not available in PROVISIONING status.
  // FIXME: Avoid polling if possible.
  Instance ins;
  do {
    await new Future.delayed(new Duration(seconds: 1));
    ins = await context.compute.instances.get(project, zone, name);
  } while (ins.status == 'PROVISIONING');

  List<String> networkIPs = ins.networkInterfaces.map((ni) => ni.networkIP);
  return new CreateVMResult(status, name, zone, networkIPs);
}

enum DeleteVMStatus { Success, Error }

class DeleteVMResult {
  // Status of DeleteVM.
  final DeleteVMStatus status;

  DeleteVMResult(this.status);
}

Future<DeleteVMResult> deleteVM(
    GCloudMixin context, String project, String zone, String name) async {
  Operation op = await context.compute.instances.delete(project, zone, name);
  DeleteVMStatus status =
      op.error == null ? DeleteVMStatus.Success : DeleteVMStatus.Error;
  return new DeleteVMResult(status);
}
