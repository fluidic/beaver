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
  String toString() {
    final buffer = new StringBuffer();
    buffer..writeln('name: $name')..writeln('config: $config');
    return buffer.toString();
  }
}
