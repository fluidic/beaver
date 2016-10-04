import 'package:gcloud/db.dart';

@Kind()
class BeaverProject extends Model {
  @StringProperty()
  String name;

  @StringProperty()
  String config;

  @IntProperty()
  int buildNumber;
}
