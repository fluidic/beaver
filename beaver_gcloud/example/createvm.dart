import 'package:args/args.dart';
import 'package:beaver_gcloud/beaver_gcloud.dart';

class GCloud extends GCloudBase {}

main(List<String> args) {
  final parser = new ArgParser()
    ..addOption('project', abbr: 'p')
    ..addOption('zone', abbr: 'z', defaultsTo: 'us-central1-a');

  final argResults = parser.parse(args);
  final gcloud = new GCloud();
  gcloud.init(argResults['project'], argResults['zone']).then((_) {
    gcloud.createVM().then((CreateVMResult result) {
      if (result.status == CreateVMStatus.Success) {
        print('createVM succeeded');
        print('\tname: ${result.name}');
        print('\texternalIP: ${result.externalIP}');
      } else {
        print('createVM failed: ${result.status}');
      }
    });
  });
}
