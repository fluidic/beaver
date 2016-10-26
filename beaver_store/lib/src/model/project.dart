import './config.dart';

class Project {
  final String name;
  Config config;

  Project(this.name);

  Map toJson() => {'project_name': name, 'config': config.toJson()};

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer..writeln('name: ${name}')..writeln('config: ${config}');
    return buffer.toString();
  }
}
