import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

import '../annotation.dart';
import '../base.dart';
import '../exception.dart';
import '../task.dart';

/// Unzip a GZip file.
@TaskClass('gunzip')
class GUnzipTask extends Task {
  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  GUnzipTask(this.src, this.dest);

  GUnzipTask.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

class UnzipException extends TaskException {
  UnzipException(String message) : super(message);
}

/// Unzip a zip file.
@TaskClass('unzip')
class UnzipTask extends Task {
  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UnzipTask(this.src, this.dest);

  UnzipTask.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<Null> execute(Context context) async {
    final srcFile = new File(src);
    if (!await srcFile.exists()) {
      throw new UnzipException('Source file \'$src\' does not exist.');
    }
    final destDirectory = new Directory(dest);
    if (!await destDirectory.exists()) {
      throw new UnzipException('Dest directory \'$dest\' does not exist.');
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
@TaskClass('untar')
class UntarTask extends Task {
  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  UntarTask(this.src, this.dest);

  UntarTask.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}

/// Unzip a BZip2 file.
@TaskClass('bunzip2')
class BUnzip2Task extends Task {
  /// Archive file to expand.
  final String src;

  /// Directory where to store the expanded files.
  final String dest;

  BUnzip2Task(this.src, this.dest);

  BUnzip2Task.fromArgs(List<String> args) : this(args[0], args[1]);

  @override
  Future<Object> execute(Context context) async {
    throw new UnimplementedError();
  }
}
