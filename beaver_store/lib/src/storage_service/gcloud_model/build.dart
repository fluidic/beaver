import 'package:gcloud/db.dart';

@Kind()
class BeaverBuild extends Model {
  @StringProperty()
  String projectId;

  @IntProperty()
  int number;

  @StringProperty()
  String triggerData;

  @StringProperty()
  String triggerType;

  @StringProperty()
  String triggerHeaders;

  @StringProperty()
  String triggerEvent;

  @StringProperty()
  String triggerUrl;

  @StringProperty()
  String taskInstance;

  @StringProperty()
  String taskInstanceStatus;

  @StringProperty()
  String taskStatus;

  @StringProperty()
  String taskConfig;

  @StringProperty()
  String log;
}
