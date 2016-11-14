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
  List<int> trigger;

  @BlobProperty()
  List<int> parsedTrigger;

  @BlobProperty()
  List<int> triggerConfig;

  @BlobProperty()
  List<int> taskRunResult;
}
