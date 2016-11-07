import './config.dart';

class Project {
  final String name;
  Config config;

  Project(this.name);

  Map toJson() {
    final json = new Map<String, Object>.from({'project_name': name});
    if (config != null) {
      json..addAll({'config': config.toJson()});
    }
    return json;
  }

  @override
  String toString() => 'name: $name\nconfig: $config';
}
