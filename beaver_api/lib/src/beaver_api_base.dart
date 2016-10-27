import 'dart:async';
import 'dart:math';

import 'package:beaver_store/beaver_store.dart';

import './formatter/html_formatter.dart';
import './formatter/text_formatter.dart';

BeaverStore _beaverStore;

void initApiHandler(BeaverStore beaverStore) {
  _beaverStore = beaverStore;
}

Future<Map<String, Object>> apiHandler(
    String api, Map<String, Object> data) async {
  final context = await _createContext();

  final ret = {};
  switch (api) {
    case 'create':
      final projectName = data['project_name'];
      final config = data['config'];
      final result =
          await _createProject(context, projectName, config: config);
      ret['project_name'] = projectName;
      ret..addAll(result);
      break;
    case 'upload':
      // FIXME: Get file by a better way.
      final projectName = data['project_name'];
      final config = data['config'];
      final result = await _uploadConfigFile(context, projectName, config);
      ret..addAll(result);
      break;
    case 'get-results':
      final projectName = data['project_name'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final count = int.parse(data['count']);
      final result =
          await _getResult(context, projectName, buildNumber, format, count);
      ret['result'] = result;
      break;
    case 'delete':
      final projectName = data['project_name'];
      await _deleteProject(context, projectName);
      break;
    case 'list':
      final result = await _listProjects(context);
      ret['project_names'] = result;
      break;
    case 'describe':
      final projectName = data['project_name'];
      final result = await _describeProject(context, projectName);
      ret..addAll(result);
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

class Context {
  // FIXME: Add logger.
  final BeaverStore beaverStore;
  Context(this.beaverStore);
}

Future<Context> _createContext() async {
  return new Context(_beaverStore);
}

/// Set new project. Returns the id of the registered project.
Future<Map<String, Object>> _createProject(Context context, String projectName,
    {String config}) async {
  await context.beaverStore.setNewProject(projectName);
  if (config != null) {
    return await _uploadConfigFile(context, projectName, config);
  }
  return {};
}

Future<Map<String, Object>> _uploadConfigFile(
    Context context, String projectName, String rawConfig) async {
  final config = await context.beaverStore.setConfig(projectName, rawConfig);
  return _getSuggestedEndpoints(projectName, config);
}

Map<String, List<Map<String, String>>> _getSuggestedEndpoints(
    String projectName, Config config) {
  // FIXME: Get this url dynamically.
  final baseAddress = '';

  final triggers = config['triggers'] as List<Map<String, Object>>;
  final endpoints = triggers.map((trigger) => { 'trigger_name': trigger['name'],
        'endpoint': baseAddress + '/' + projectName + '/' + trigger['name']
      }).toList(growable: false);

  return {'endpoints': endpoints};
}

Future<String> _getResult(Context context, String projectName, int buildNumber,
    String format, int count) async {
  final project = await context.beaverStore.getProject(projectName);
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

  switch (format) {
    case 'html':
      final formatter = new HtmlFormatter(project, results);
      return formatter.toHtml();
    case 'text':
    default:
      final formatter = new TextFormatter(project, results);
      return formatter.toText();
  }
}

Future<Null> _deleteProject(Context context, String projectName) =>
    context.beaverStore.deleteProject(projectName);

Future<List<String>> _listProjects(Context context) async {
  final projects = await context.beaverStore.listProjects();
  return projects.map((project) => project.name).toList(growable: false);
}

Future<Map<String, Object>> _describeProject(
    Context context, String projectName) async {
  final project = await context.beaverStore.getProject(projectName);
  if (project == null) {
    throw new Exception('Project doesn\'t exist for name \'${projectName}\'');
  }
  final endpoints = _getSuggestedEndpoints(projectName, project.config);
  return {'project': project.toJson()}..addAll(endpoints);
}
