import './config.dart';

class Project {
  final String name;
  String id;
  Config config;

  Project(this.name);

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer
      ..writeln('name: ${name}')
      ..writeln('id: ${id}')
      ..writeln('config: ${config}');
    return buffer.toString();
  }
}
