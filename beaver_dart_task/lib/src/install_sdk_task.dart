import 'dart:async';
import 'dart:io' show Platform;

import 'package:beaver_task/beaver_task.dart';

@TaskClass('install_dart_sdk')
class InstallDartSdkTask extends Task {
  final String version;

  InstallDartSdkTask(this.version);

  InstallDartSdkTask.fromArgs(List<String> args) : version = args[0];

  @override
  Future<Null> execute(Context context) async {
    var stableOrDev = 'stable';
    if (version.contains('dev')) {
      stableOrDev = 'dev';
    }

    var platform = 'macos';
    if (Platform.isLinux) {
      platform = 'linux';
    } else if (Platform.isWindows) {
      platform = 'windows';
    }

    final sdk =
        'https://storage.googleapis.com/dart-archive/channels/$stableOrDev/release/$version/sdk/dartsdk-$platform-x64-release.zip';
    await seq([
      new DownloadTask(sdk, '.'),
      new UnzipTask('dartsdk-$platform-x64-release.zip', '.')
    ]).execute(context);
  }
}
