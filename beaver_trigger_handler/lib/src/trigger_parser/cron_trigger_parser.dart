import '../base.dart';

@TriggerParserClass('cron')
class CronTriggerParser implements TriggerParser {
  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    return new ParsedTrigger('', '', trigger.data);
  }
}
