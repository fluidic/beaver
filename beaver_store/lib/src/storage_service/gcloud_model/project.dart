import 'package:gcloud/db.dart';

@Kind()
class BeaverProject extends Model {
  // FIXME: id could be used.
  @StringProperty()
  String projectId;

  @StringProperty()
  String name;

  @StringProperty()
  String config;

  @IntProperty()
  int buildNumber;
}
