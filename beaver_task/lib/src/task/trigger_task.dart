import 'dart:async';

import './post_task.dart';

import '../annotation.dart';
import '../base.dart';
import '../task.dart';

@TaskClass('trigger')
class TriggerTask extends Task {
  final String triggerName;

  TriggerTask(this.triggerName);

  TriggerTask.fromArgs(List<String> args) : triggerName = args[0];

  @override
  Future<Null> execute(Context context) async {
    final url = [
      context.config.buildInfo['request_url'],
      context.config.buildInfo['project_name'],
      triggerName
    ];
    final post = new PostTask(url.join('/'), {});
    final response = await post.execute(context);
    context.logger.info(response.body.toString());
  }
}
