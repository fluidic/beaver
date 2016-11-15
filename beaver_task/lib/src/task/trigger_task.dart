import 'dart:async';

import 'package:args/args.dart';

import './post_task.dart';
import '../annotation.dart';
import '../base.dart';
import '../task.dart';

@TaskClass('trigger')
class TriggerTask extends Task {
  final String triggerName;
  final String projectName;

  TriggerTask(this.triggerName, {String projectName})
      : this.projectName = projectName;

  factory TriggerTask.fromArgs(List<String> args) {
    final parser = new ArgParser(allowTrailingOptions: true)
      ..addOption('project-name', abbr: 'C');
    final results = parser.parse(args);
    return new TriggerTask(results.rest[0],
        projectName: results['project-name']);
  }

  @override
  Future<Null> execute(Context context) async {
    final url = [
      context.config.buildInfo['request_url'],
      projectName != null
          ? projectName
          : context.config.buildInfo['project_name'],
      triggerName
    ];
    final post = new PostTask(url.join('/'), {});
    final response = await post.execute(context);
    context.logger.info(response.body.toString());
  }
}
