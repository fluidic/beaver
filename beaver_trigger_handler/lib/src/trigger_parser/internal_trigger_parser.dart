import '../base.dart';

@TriggerParserClass('internal')
class InternalTriggerParser implements TriggerParser {
  @override
  ParsedTrigger parse(Context context, Trigger trigger) {
    return new ParsedTrigger('', '', trigger.payload);
  }
}
