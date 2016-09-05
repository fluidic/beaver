import 'package:beaver_task/beaver_task.dart';

// FIXME: This model should have the key-value configuration data that made from
// configFile.
class Project {
  final String name;
  String id;
  Config config;
  Uri configFile;
  int buildNumber;

  Project(this.name) : buildNumber = 0;
}
