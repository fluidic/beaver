import 'dart:async';
import 'dart:io';

import 'package:beaver_store/beaver_store.dart';

Future<Null> main() async {
  final store = new BeaverStore(StorageServiceType.localMachine);

  final projectName = 'beaver';
  final id = await store.setNewProject(projectName);
  print(id);

  final yaml = _loadYamlFile('./beaver.yaml');
  await store.setConfig(projectName, yaml);

  final project = await store.getProject(projectName);
  print(project.config['project']);
  print(project.config['description']);
}

String _loadYamlFile(String path) {
  return new File(path).readAsStringSync();
}
