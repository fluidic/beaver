import 'dart:async';

import './beaver_store_base.dart';
import './connector/gcloud_connector.dart';
import './connector/local_machine_connector.dart';
import './model/project.dart';

abstract class Connector {
  Future<Project> load(String id);
  Future<String> save(Project project);
}

final Map<ConnectorType, CreateConnector> _map = {
  ConnectorType.localMachine: () => new LocalMachineConnector(),
  ConnectorType.gCloud: () => new GCloudConnector()
};

typedef Connector CreateConnector();

Connector getConnector(ConnectorType connectorType) {
  return _map[connectorType]();
}
