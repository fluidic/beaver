import 'package:beaver_core/beaver_core.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';

main() => runBeaver(seq([
      par([
        new InstallDartSdkTask(withContentShell: true, withDartium: true),
        new GitTask(['clone', 'git@github.com:fluidic/symbol.git'])
      ]),
      new PubTask(['get'], processWorkingDir: 'symbol'),
      new PubTask(['run', 'test'], processWorkingDir: 'symbol')
    ]));
