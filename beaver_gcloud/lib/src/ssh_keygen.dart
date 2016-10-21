import 'dart:async';
import 'dart:io';

import 'package:command_wrapper/command_wrapper.dart';
import 'package:file_helper/file_helper.dart';
import 'package:path/path.dart' as path;

final String _homePath = Platform.isWindows
    ? Platform.environment['APPDATA']
    : Platform.environment['HOME'];

final CommandWrapper _sshKeygen = new CommandWrapper('ssh-keygen');

final String _beaverDir = path.join(_homePath, '.beaver');
final String _sshKeyPath = path.join(_beaverDir, 'id_rsa');

final String sshPublicKeyPath = '${_sshKeyPath}.pub';

Future<Null> generateSshKeyIfNotExist() async {
  if (await new File(_sshKeyPath).exists()) return;

  if (!await new File(_beaverDir).exists()) {
    await mkdir([_beaverDir], recursive: true);
  }

  const username = 'beaver';
  CommandResult result =
      await _sshKeygen.run(['-t', 'rsa', '-f', _sshKeyPath, '-C', username]);
  if (result.exitCode != 0) {
    throw new Exception('Fail to create ssh key');
  }

  final contents = await new File(sshPublicKeyPath).readAsString();
  // If we use the API to set public SSH keys, we must prefix the key with our
  // username. See https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
  await new File(sshPublicKeyPath)
      .writeAsString('${username}:${contents}', flush: true);
}
