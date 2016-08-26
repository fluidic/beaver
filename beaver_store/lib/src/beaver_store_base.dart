import 'dart:async';

import './connector.dart';
import './models/config.dart';
import './models/project.dart';

enum ConnectorType { mapInMemory, gCloudDataStore }

class ProjectStore {
  final Connector _connector;

  ProjectStore(ConnectorType connectorType)
      : _connector = getConnector(connectorType);

  /// Return the id of Project.
  Future<String> setNewProject(String name) {
    return _connector.save(new Project(name));
  }

  Future<Project> getProject(String id) {
    return _connector.load(id);
  }

  Future<Null> setConfig(String id, String yaml) async {
    // FIXME: Upload the config file to the specific location.
    final config = new Config(yaml);
    final project = await _connector.load(id);
    if (project.name != config['project']) {
      throw new Exception('Project name is not valid.');
    }
    project.config = config;
    _connector.save(project);
  }
}
