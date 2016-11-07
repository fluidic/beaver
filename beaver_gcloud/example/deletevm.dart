import 'package:args/args.dart';
import 'package:beaver_gcloud/beaver_gcloud.dart';

class GCloud extends GCloudBase {}

void main(List<String> args) {
  final parser = new ArgParser()
    ..addOption('project', abbr: 'p')
    ..addOption('zone', abbr: 'z', defaultsTo: 'us-central1-a');

  final argResults = parser.parse(args);
  if (argResults.rest.length != 1) {
    print(parser.usage);
    return;
  }

  final instanceName = argResults.rest.first;
  final gcloud = new GCloud();
  gcloud.init(argResults['project'], argResults['zone']).then((_) {
    gcloud.deleteVM(instanceName).then((DeleteVMResult result) {
      if (result.status == DeleteVMStatus.success) {
        print('deleteVM succeeded');
      } else {
        print('deleteVM failed: ${result.status}');
      }
    });
  });
}
