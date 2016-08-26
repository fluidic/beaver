import 'dart:async';

import './models/project.dart';
import './connectors/map_in_memory_connector.dart';
import './connectors/gcloud_datastore_connector.dart';
import './beaver_store_base.dart';

abstract class Connector {
  Future<Project> load(String id);
  Future<String> save(Project project);
}

final Map<ConnectorType, CreateConnector> _map = {
  ConnectorType.mapInMemory: () => new MapInMemoryConnector(),
  ConnectorType.gCloudDataStore: () => new GCloudDatastoreConnector()
};

typedef Connector CreateConnector();

Connector getConnector(ConnectorType connectorType) {
  return _map[connectorType]();
}
