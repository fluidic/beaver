import 'package:beaver_task/beaver_task.dart';

class Project {
  final String name;
  String id;
  Config config;
  Uri configFile;
  int buildNumber;

  Project(this.name) : buildNumber = 0;
}
