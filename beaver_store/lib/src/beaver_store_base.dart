import 'dart:async';

import './connector.dart';
import './model/config.dart';
import './model/project.dart';

enum ConnectorType { localMachine, gCloud }

class ProjectStore {
  final Connector _connector;

  ProjectStore(ConnectorType connectorType)
      : _connector = getConnector(connectorType);

  /// Return the id of Project.
  Future<String> setNewProject(String name) {
    return _connector.saveProject(new Project(name));
  }

  Future<Project> getProject(String id) {
    return _connector.loadProject(id);
  }

  Future<Null> setConfig(String id, String yaml) async {
    final config = new Config(yaml);
    final project = await _connector.loadProject(id);
    if (project == null) {
      throw new Exception('No project for ${id}');
    }
    if (project.name != config['project']) {
      throw new Exception('Project name is not valid.');
    }
    project.config = config;
    project.configFile = await _connector.saveConfigFile(project.id, yaml);
    await _connector.saveProject(project);
  }
}
