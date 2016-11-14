import 'package:beaver_task/beaver_task_runner.dart';
import 'package:beaver_trigger_handler/beaver_trigger.dart';

class TriggerResult {
  final String projectName;
  final int buildNumber;

  final String status;

  final Trigger trigger;
  final ParsedTrigger parsedTrigger;
  final Map<String, Object> triggerConfig;

  final TaskRunResult taskRunResult;

  TriggerResult(this.projectName, this.buildNumber, this.status, this.trigger,
      this.parsedTrigger, this.triggerConfig, this.taskRunResult);
}
