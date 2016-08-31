import 'dart:async';

import '../connector.dart';
import '../models/project.dart';

class GCloudConnector implements Connector {
  @override
  Future<Project> load(String id) async {
    // FIXME: Implement.
    throw new Exception('Not implemented.');
  }

  @override
  Future<String> save(Project project) async {
    // FIXME: Implement.
    throw new Exception('Not implemented.');
  }
}
