import 'dart:io';

import 'package:beaver_store/beaver_store.dart';

main() async {
  final store = new ProjectStore(ConnectorType.mapInMemory);

  final id = await store.setNewProject('beaver');
  print(id);

  final yaml = _loadYamlFile('./beaver.yaml');
  await store.setConfig(id, yaml);

  final project = await store.getProject(id);
  print(project.config['project']);
  print(project.config['description']);
}

String _loadYamlFile(String path) {
  return new File(path).readAsStringSync();
}
