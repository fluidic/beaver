import 'dart:async';

import 'package:beaver_gcloud_task/beaver_gcloud_task.dart';

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

@TaskClass('mail')
class MailTask extends Task {
  /// Receiver mail address.
  final String to;

  MailTask(this.to);

  MailTask.fromArgs(List<String> args) : this(args[0]);

  @override
  Future<Object> execute(Context context) {
    final subject = 'Beaver CI Mail Notification';
    // FIXME: Pass trigger_handler's info like build number.
    final content = '''
    Task is triggerred.
    Project Name: ${context.config.buildInfo['project_name']}
    Trigger Name: ${context.config.buildInfo['trigger_name']}
    Build Number: ${context.config.buildInfo['build_number']}
    Task Log: ${context.logger.toString()}
    ''';

    var task;
    switch (context.config.cloudType) {
      case 'gcloud':
        task = new GCloudMailTask(to, subject, content);
        break;
      default:
        // FIXME: Support the other cloud platforms.
        throw new TaskException('Not supported cloud type.');
    }

    return task.execute(context);
  }
}
