import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

import './beaver_core_base.dart';

/// Unzip a GZip file.
class GUnzipTask extends Task {
  @override
  String get name => "gunzip";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  GUnzipTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

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
  Future<Null> execute(Context context) async {
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
      final entry = path.join(dest, archiveFile.name);

      if (_isDirectory(entry)) {
        final dir = new Directory(entry);
        await dir.create(recursive: true);
      } else {
        final file = new File(entry);
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

/// Untar a Tar file.
class UntarTask extends Task {
  @override
  String get name => "untar";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UntarTask(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

/// Unzip a BZip2 file.
class BUnzip2Task extends Task {
  @override
  String get name => "bunzip2";

  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  BUnzip2Task(this.src, this.dest);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}
