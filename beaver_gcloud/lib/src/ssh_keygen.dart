import 'dart:async';
import 'dart:io';

import 'package:command_wrapper/command_wrapper.dart';
import 'package:path/path.dart' as path;

final CommandWrapper _sshKeygen = new CommandWrapper('ssh-keygen');

final String sshKeyPath = path.join('/tmp', 'id_rsa');
final String sshPublicKeyPath = '$sshKeyPath.pub';

Future<Null> generateSshKeyIfNotExist() async {
  if (await new File(sshKeyPath).exists()) return;

  const username = 'beaver';
  CommandResult result =
      await _sshKeygen.run(['-t', 'rsa', '-f', sshKeyPath, '-C', username, '-N', '']);
  if (result.exitCode != 0) {
    throw new Exception('Fail to create ssh key');
  }

  final contents = await new File(sshPublicKeyPath).readAsString();
  // If we use the API to set public SSH keys, we must prefix the key with our
  // username. See https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
  await new File(sshPublicKeyPath)
      .writeAsString('$username:$contents', flush: true);
}
