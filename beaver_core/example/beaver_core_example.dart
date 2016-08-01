import 'package:beaver_core/beaver_core.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';
/// For [GCloudContextPart] registration
import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';

main() => runBeaver([
      new InstallDartSdkTask(withContentShell: true, withDartium: true),
      new PubTask(['get'], processWorkingDir: 'symbol'),
      new PubTask(['run', 'test'], processWorkingDir: 'symbol')
    ]);

