import 'dart:io';

import 'package:beaver_config_store/beaver_config_store.dart';

main() async {
  final store = new ConfigStore(StorageServiceType.localMachine);

  final id = await store.setNewProject('beaver');
  print(id);

  final yaml = _loadYamlFile('./beaver.yaml');
  await store.setConfig(id, yaml);

  final project = await store.getProject(id);
  print(project.config['project']);
  print(project.config['description']);
  print(project.configFile);
}

String _loadYamlFile(String path) {
  return new File(path).readAsStringSync();
}
