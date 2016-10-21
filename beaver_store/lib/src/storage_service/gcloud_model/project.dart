import 'package:gcloud/db.dart';

@Kind()
class BeaverProject extends Model {
  @StringProperty()
  String name;

  @BlobProperty()
  List<int> config;

  @IntProperty()
  int buildNumber;
}
