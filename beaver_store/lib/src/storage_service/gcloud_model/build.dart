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
  String parsedTriggerEvent;

  @StringProperty()
  String parsedTriggerUrl;

  @StringProperty()
  String taskInstance;

  @StringProperty()
  String taskInstanceStatus;

  @StringProperty()
  String taskStatus;

  @StringProperty()
  String taskConfigCloudType;

  @StringProperty()
  String taskConfigCloudSettings;

  @BlobProperty()
  List<int> taskLog;
}
