import 'dart:async';

import 'package:beaver_dart_task/beaver_dart_task.dart';
import 'package:beaver_task/beaver_task.dart';

@TaskClass('dart_package_test')
class DartPackageTestTask implements Task {
  final String packageName;
  final String packageUrl;
  final String commitHash;

  DartPackageTestTask(this.packageName, this.packageUrl, this.commitHash);

  DartPackageTestTask.fromArgs(List<String> args)
      : packageName = args[0],
        packageUrl = args[1],
        commitHash = args[2];

  @override
  // FIXME: Use par.
  Future<Object> execute(Context context) => seq([
        new GitTask(['clone', '${packageUrl}', '${packageName}']),
        new GitTask(['checkout', '${commitHash}'],
            processWorkingDir: '${packageName}'),
        new PubTask(['get'], processWorkingDir: '${packageName}'),
        new PubTask(['run', 'test'], processWorkingDir: '${packageName}')
      ]).execute(context);
}
