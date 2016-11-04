import 'dart:async';
import 'dart:math';

import 'package:beaver_store/beaver_store.dart';

import './formatter/html_formatter.dart';
import './formatter/text_formatter.dart';

BeaverStore _beaverStore;

void initApiHandler(BeaverStore beaverStore) {
  _beaverStore = beaverStore;
}

Future<Map<String, Object>> apiHandler(String api, Map<String, Object> data) {
  final context = _createContext();

  switch (api) {
    case 'create':
      final projectName = data['project_name'];
      final config = data['config'];
      return _createProject(context, projectName, config: config);
    case 'upload':
      // FIXME: Get file by a better way.
      final projectName = data['project_name'];
      final config = data['config'];
      return _uploadConfigFile(context, projectName, config);
    case 'get-results':
      final projectName = data['project_name'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final count = int.parse(data['count']);
      return _getResult(context, projectName, buildNumber, format, count);
    case 'delete':
      final projectName = data['project_name'];
      return _deleteProject(context, projectName);
    case 'list':
      return _listProjects(context);
    case 'describe':
      final projectName = data['project_name'];
      return _describeProject(context, projectName);
    default:
      throw new Exception('Wrong API.');
  }
}

class Context {
  // FIXME: Add logger.
  final BeaverStore beaverStore;
  Context(this.beaverStore);
}

Context _createContext() {
  return new Context(_beaverStore);
}

Future<Map<String, Object>> _createProject(Context context, String projectName,
    {String config}) async {
  await context.beaverStore.setNewProject(projectName);
  var endpoints = new Map<String, Object>();
  if (config != null) {
    endpoints = await _uploadConfigFile(context, projectName, config);
  }
  return {'project_name': projectName}..addAll(endpoints);
}

Future<Map<String, Object>> _uploadConfigFile(
    Context context, String projectName, String rawConfig) async {
  final config = await context.beaverStore.setConfig(projectName, rawConfig);
  return _getSuggestedEndpoints(projectName, config);
}

Map<String, List<Map<String, String>>> _getSuggestedEndpoints(
    String projectName, Config config) {
  assert(config != null);
  assert(config['triggers'] != null);

  final triggers = config['triggers'] as List<Map<String, Object>>;
  final endpoints = triggers
      .map((trigger) => new Map<String, String>.from({
            'trigger_name': trigger['name'],
            'endpoint': '/' + projectName + '/' + trigger['name']
          }))
      .toList(growable: false);

  return {'endpoints': endpoints};
}

Future<Map<String, Object>> _getResult(Context context, String projectName,
    int buildNumber, String format, int count) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    throw new Exception('No project for \'${projectName}\'.');
  }
  final resultBuildNumbers =
      new Iterable.generate(max(count, 0), (i) => buildNumber + i);
  final results = (await Future.wait(resultBuildNumbers.map((number) async {
    try {
      return await context.beaverStore.getResult(projectName, number);
    } on NullThrownError {
      return null;
    }
  })))
      .toList()..removeWhere((result) => result == null);

  var result;
  switch (format) {
    case 'html':
      final formatter = new HtmlFormatter(project, results);
      result = formatter.toHtml();
      break;
    case 'text':
    default:
      final formatter = new TextFormatter(project, results);
      result = formatter.toText();
  }
  return {'result': result};
}

Future<Map<String, Object>> _deleteProject(
    Context context, String projectName) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    throw new Exception('Project \'${projectName}\' doesn\'t exist.');
  }
  await context.beaverStore.deleteProject(projectName);
  return {};
}

Future<Map<String, List<String>>> _listProjects(Context context) async {
  final projects = await context.beaverStore.listProjects();
  final projectNames =
      projects.map((project) => project.name).toList(growable: false);
  return {'project_names': projectNames};
}

Future<Map<String, Object>> _describeProject(
    Context context, String projectName) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    throw new Exception('Project doesn\'t exist for name \'${projectName}\'');
  }
  final result = new Map<String, Object>.from({'project': project.toJson()});
  if (project.config != null) {
    final endpoints = _getSuggestedEndpoints(projectName, project.config);
    result..addAll(endpoints);
  }
  return result;
}
