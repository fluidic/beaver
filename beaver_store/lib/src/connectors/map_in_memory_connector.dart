import 'dart:async';

import 'package:uuid/uuid.dart';

import '../connector.dart';
import '../models/project.dart';

final Map<String, Project> _map = {};

class MapInMemoryConnector implements Connector {
  const MapInMemoryConnector();

  @override
  Future<Project> load(String id) async {
    return _map[id];
  }

  @override
  Future<String> save(Project project) async {
    if (project.id == null) {
      final id = new Uuid().v4();
      project.id = id;
    }
    _map[project.id] = project;
    return project.id;
  }
}
