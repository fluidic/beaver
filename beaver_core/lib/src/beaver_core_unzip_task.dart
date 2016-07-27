// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';

import './beaver_core_base.dart';

class UnzipException extends TaskException {
  final String _message;

  UnzipException(this._message);

  @override
  String toString() => _message;
}

/// Unzip a zip file.
class UnzipTask extends Task {
  @override
  String get name => "unzip";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UnzipTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    final srcFile = new File(src);
    if (!await srcFile.exists()) {
      throw new UnzipException('Source file \'${src}\' does not exist.');
    }
    final destDirectory = new Directory(dest);
    if (!await destDirectory.exists()) {
      throw new UnzipException('Dest directory \'${dest}\' does not exist.');
    }

    List<int> bytes = await srcFile.readAsBytes();
    Archive archive = new ZipDecoder().decodeBytes(bytes);

    for (ArchiveFile archiveFile in archive) {
      final path = '${dest}/${archiveFile.name}';

      if (_isDirectory(path)) {
        final dir = new Directory(path);
        await dir.create(recursive: true);
      } else {
        final file = new File(path);
        await file.create(recursive: true);
        await file.writeAsBytes(archiveFile.content);
      }
    }
  }

  static bool _isDirectory(String path) {
    // FIXME: ArchiveFile.isFile doesn't work. A better way?
    return path.endsWith('/');
  }
}
