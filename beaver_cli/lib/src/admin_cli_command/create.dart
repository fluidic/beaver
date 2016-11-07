import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:yaml/yaml.dart';

import '../exit_codes.dart';

final gcloudCli = new CommandWrapper('gcloud');

class CreateCommand extends Command {
  @override
  String get description => 'Create a beaver CI env';

  @override
  String get name => 'create';

  CreateCommand() : super() {
    argParser.addOption('project',
        abbr: 'p',
        help: 'The cloud project ID to use for setting up beaver CI');
  }

  /// Deploys the function to gcloud and returns the trigger URL.
  Future<String> deploy(String project) async {
    final functionName = 'beaver-functions-${uniqueName()}';
    final url = 'https://source.developers.google.com/p/${project}/r/default';
    await gcloudCli.run([
      'alpha',
      'functions',
      'deploy',
      functionName,
      '--source-url',
      url,
      '--source-path',
      '/functions',
      '--source-branch',
      'master',
      '--entry-point',
      'beaver',
      '--trigger-http'
    ]);
    CommandResult result =
        await gcloudCli.run(['alpha', 'functions', 'describe', functionName]);
    final desc = loadYaml(result.stdout.join('\n'));
    return desc['httpsTrigger']['url'];
  }

  @override
  Future<Null> run() async {
    final project = argResults['project'];
    if (project == null) {
      print('project is required.');
      print(usage);
      exit(exitCodeError);
    }
    final endpoint = await deploy(project);
    final yaml = toYamlString({'project': project, 'endpoint': endpoint});
    writeTextFile(beaverAdminConfigPath, yaml);
    print(yaml);
  }
}
