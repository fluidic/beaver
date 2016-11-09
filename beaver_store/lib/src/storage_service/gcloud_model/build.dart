import 'package:gcloud/db.dart';

@Kind()
class BeaverBuild extends Model {
  @StringProperty()
  String projectName;

  @IntProperty()
  int number;

  @StringProperty()
  String status;

  @BlobProperty()
  List<int> triggerPayload;

  @StringProperty()
  String triggerName;

  @StringProperty()
  String triggerHeaders;

  @StringProperty()
  String parsedTriggerEvent;

  @StringProperty()
  String parsedTriggerUrl;

  @StringProperty()
  String taskInstance;

  @StringProperty()
  String taskStatus;

  @StringProperty()
  String taskConfigCloudType;

  @StringProperty()
  String taskConfigCloudSettings;

  @BlobProperty()
  List<int> taskLog;
}
