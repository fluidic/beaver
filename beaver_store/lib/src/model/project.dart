import 'package:beaver_task/beaver_task.dart';

class Project {
  final String name;
  String id;
  Config config;
  Uri configFile;

  Project(this.name);

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer
      ..writeln('name: ${name}')
      ..writeln('id: ${id}')
      ..writeln('config: ${config}')
      ..writeln('configFile: ${configFile}');
    return buffer.toString();
  }
}
