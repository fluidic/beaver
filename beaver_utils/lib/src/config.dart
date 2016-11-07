import 'dart:io';

import 'package:path/path.dart' as path;

final String homePath = Platform.isWindows
    ? Platform.environment['APPDATA']
    : Platform.environment['HOME'];

final String beaverConfigDir = path.join(homePath, '.beaver');

final beaverLocalConfigPath = 'beaver-config.yaml';

final beaverGlobalConfigPath = path.join(homePath, '.beaver-config.yaml');

final String beaverAdminConfigPath =
    path.join(beaverConfigDir, 'beaver_admin.yaml');
