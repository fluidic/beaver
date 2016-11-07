import 'dart:async';

import './git_task.dart';
import '../annotation.dart';
import '../base.dart';
import '../task.dart';

@TaskClass('version_check')
class VersionCheckTask extends Task {
  final String gitRepo;
  final String versionTag;

  VersionCheckTask(this.gitRepo, this.versionTag);

  VersionCheckTask.fromArgs(List<String> args)
      : gitRepo = args[0],
        versionTag = args[1];

  static const String workingDir = 'version_check';

  @override
  Future<Null> execute(Context context) => seq([
        new GitTask(['clone', gitRepo, workingDir]),
        new GitTask(['show', versionTag], processWorkingDir: workingDir)
      ]).execute(context);
}
