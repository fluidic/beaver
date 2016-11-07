import 'dart:io';

import 'package:path/path.dart' as path;

final String _homePath = Platform.isWindows
    ? Platform.environment['APPDATA']
    : Platform.environment['HOME'];

final String beaverConfigDir = path.join(_homePath, '.beaver');

final String beaverAdminConfigPath =
    path.join(beaverConfigDir, 'beaver_admin.yaml');
