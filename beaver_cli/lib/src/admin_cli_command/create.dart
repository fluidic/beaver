import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:beaver_utils/beaver_utils.dart';
import 'package:command_wrapper/command_wrapper.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../exit_codes.dart' as exit_codes;
import '../exceptions.dart';

final _gcloudCli = new CommandWrapper('gcloud');
final _gsutil = new CommandWrapper('gsutil');
final _sshKeygen = new CommandWrapper('ssh-keygen');

final String _sshKeyPath = path.join(beaverConfigDir, 'id_rsa');
final String _sshPublicKeyPath = '$_sshKeyPath.pub';

class CreateCommand extends Command {
  @override
  String get description => 'Create a beaver CI env';

  @override
  String get name => 'create';

  CreateCommand() {
    argParser.addOption('project',
        abbr: 'p',
        help: 'The cloud project ID to use for setting up beaver CI');
  }

  Future<Null> _generateSshKeyIfNotExist() async {
    if (await new File(_sshKeyPath).exists()) return;

    const username = 'beaver';
    CommandResult result = await _sshKeygen
        .run(['-t', 'rsa', '-f', _sshKeyPath, '-C', username, '-N', '']);
    if (result.exitCode != exit_codes.success) {
      throw new ApplicationException('Fail to create ssh key');
    }

    final contents = await readTextFile(_sshPublicKeyPath);
    // If we use the API to set public SSH keys, we must prefix the key with our
    // username. See https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
    await writeTextFile(_sshPublicKeyPath, '$username:$contents');
  }

  Future<Null> _uploadSshKey(String project, String siteId) async {
    final bucketUrl = 'gs://beaver-$siteId';
    CommandResult result = await _gsutil.run(['ls']);
    if (!result.stdout.contains(bucketUrl)) {
      await _gsutil.run(['mb', '-p', project, bucketUrl]);
    }
    await _gsutil.run(['cp', _sshKeyPath, _sshPublicKeyPath, bucketUrl]);
  }

  /// Deploys the function to gcloud and returns the trigger URL.
  Future<String> _deploy(String project, String siteId) async {
    final functionName = 'beaver-functions-$siteId';
    final url = 'https://source.developers.google.com/p/$project/r/default';
    await _gcloudCli.run([
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
        await _gcloudCli.run(['alpha', 'functions', 'describe', functionName]);
    final desc = loadYaml(result.stdout.join('\n'));
    return desc['httpsTrigger']['url'];
  }

  @override
  Future<Null> run() async {
    final siteId = uniqueName();
    final project = argResults['project'];
    if (project == null) {
      print('project is required.');
      print(usage);
      exit(exit_codes.usage);
    }

    await createFileIfNotExist(beaverAdminConfigPath);
    final config = await readYamlFile(beaverAdminConfigPath);
    String endpoint = await _deploy(project, siteId);
    config['sites'] ??= [];
    config['sites']
        .add({'site_id': siteId, 'project': project, 'endpoint': endpoint});

    await _generateSshKeyIfNotExist();
    await _uploadSshKey(project, siteId);

    await writeYamlFile(beaverAdminConfigPath, config);
  }
}
