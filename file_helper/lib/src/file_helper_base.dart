// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path_lib;

/// Creates directories.
///
/// Returns `true` if the operation was successful; otherwise `false`.
///
/// If directories exist, returns `false`.
/// If [recursive] is set to `true`, creates all the required subdirectories and
/// returns `true` if no errors occurred.
Future<bool> mkdir(Iterable<String> paths, {bool recursive: false}) async {
  if (paths == null || paths.isEmpty) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    final directory = new Directory(path);
    if (await directory.exists()) {
      if (!recursive) {
        result = false;
      }
    } else {
      try {
        await directory.create(recursive: recursive);
      } catch (e) {
        result = false;
      }
    }
  }

  return result;
}

/// Copies paths to the directory.
///
/// Returns `true` if the operation was successful; otherwise `false`.
Future<bool> copy(Iterable<String> paths, String dir) async {
  if (paths == null || dir == null) {
    return false;
  }

  if (!await FileSystemEntity.isDirectory(dir)) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    if (path.isEmpty) {
      result = false;
      continue;
    }

    final basename = path_lib.basename(path);
    if (basename.isEmpty) {
      result = false;
      continue;
    }
    final dest = path_lib.join(dir, basename);

    FileSystemEntity srcEntity = await _getEntity(path);
    if (srcEntity is Directory) {
      final destDirEntity = await new Directory(dest)..create();
      await for (final entity
          in srcEntity.list(recursive: true, followLinks: false)) {
        final relPath = path_lib.relative(entity.path, from: srcEntity.path);
        final destPath = path_lib.join(destDirEntity.path, relPath);
        if (entity is Directory) {
          await new Directory(destPath).create(recursive: true);
        } else if (entity is File) {
          entity.copy(destPath);
        } else if (entity is Link) {
          final target = await entity.target();
          await new Link(destPath).create(target);
        } else {
          result = false;
        }
      }
    } else if (srcEntity is File) {
      await srcEntity.copy(dest);
    } else if (srcEntity is Link) {
      final target = await srcEntity.target();
      await new Link(dest).create(target);
    } else {
      result = false;
      continue;
    }
  }

  return result;
}

/// Moves paths to the directory.
///
/// Returns `true` if the operation was successful; otherwise `false`.
Future<bool> move(Iterable<String> paths, String dir) async {
  if (paths == null || dir == null) {
    return false;
  }

  if (!await FileSystemEntity.isDirectory(dir)) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    if (path.isEmpty) {
      result = false;
      continue;
    }

    final basename = path_lib.basename(path);
    if (basename.isEmpty) {
      result = false;
      continue;
    }

    final dest = path_lib.join(dir, basename);
    if (!await rename(path, dest)) {
      result = false;
    }
  }

  return result;
}

/// Renames [oldPath] to [newPath].
///
/// Returns `true` if the operation was successful; otherwise `false`.
Future<bool> rename(String oldPath, String newPath) async {
  if (oldPath == null || newPath == null) {
    return false;
  }

  FileSystemEntity entity = await _getEntity(oldPath);
  if (entity == null) {
    return false;
  }

  try {
    await entity.rename(newPath);
  } catch (e) {
    return false;
  }

  return true;
}

/// Removes paths.
///
/// Returns `true` if the operation was successful; otherwise `false`.
///
/// By default, it does not remove directories.
/// If [directory] is set to `true`, removes the directories if they are empty.
/// If [force] is set to `true`, ignores nonexistent files.
/// If [recursive] is set to `true`, remove the directories and their contents
/// recursively.
Future<bool> rm(Iterable<String> paths,
    {bool directory: false, bool force: false, bool recursive: false}) async {
  if (paths == null || paths.isEmpty) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    if (path.isEmpty) {
      if (!force) {
        result = false;
      }

      continue;
    }

    FileSystemEntity entity = await _getEntity(path);

    if (entity == null) {
      if (!force) {
        result = false;
      }
    } else {
      if (entity is Directory) {
        if (recursive) {
          try {
            await entity.delete(recursive: recursive);
          } catch (e) {
            result = false;
          }
        } else if (directory) {
          result = rmdir([entity.path]);
        } else {
          result = false;
        }
      } else {
        try {
          await entity.delete();
        } catch (e) {
          result = false;
        }
      }
    }
  }

  return result;
}

/// Removes empty directories.
///
/// Returns `true` if the operation was successful; otherwise `false`.
Future<bool> rmdir(Iterable<String> paths) async {
  if (paths == null || paths.isEmpty) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    if (path.isEmpty) {
      result = false;
      continue;
    }

    if (!await FileSystemEntity.isDirectory(path)) {
      result = false;
      continue;
    }

    if (await _isEmptyDir(path)) {
      try {
        await new Directory(path).delete();
      } catch (e) {
        result = false;
      }
    } else {
      result = false;
    }
  }

  return result;
}

/// Changes the modification time of the specified paths.
///
/// Returns `true` if the operation was successful; otherwise `false`.
///
/// If [create] is set to `true`, creates files that do not exist, reports
/// failure if the files can not be created.
/// If [create] is set to `false`, do not create files that do not exist and
/// do not report failure about files that do not exist.
Future<bool> touch(Iterable<String> paths, {bool create: true}) async {
  if (paths == null || paths.isEmpty) {
    return false;
  }

  var result = true;
  for (final path in paths) {
    if (path.isEmpty) {
      result = false;
      continue;
    }

    if (Platform.isWindows) {
      // FIXME: Implement.
      throw new UnimplementedError();
    } else {
      if (!await _touchOnPosix(path, create)) {
        result = false;
      }
    }
  }

  return result;
}

Future<FileSystemEntity> _getEntity(String path) async {
  final type = await FileSystemEntity.type(path);
  switch (type) {
    case FileSystemEntityType.DIRECTORY:
      return new Directory(path);
    case FileSystemEntityType.FILE:
      return new File(path);
    case FileSystemEntityType.LINK:
      return new Link(path);
    case FileSystemEntityType.NOT_FOUND:
    default:
      return null;
  }
}

Future<int> _shell(String command, Iterable<String> arguments,
    {String workingDirectory}) async {
  return (await Process.run(command, arguments,
          runInShell: true, workingDirectory: workingDirectory))
      .exitCode;
}

Future<bool> _touchOnPosix(String path, bool create) async {
  final arguments = <String>[path];
  if (!create) {
    arguments.add("-c");
  }

  return await _shell("touch", arguments) == 0;
}

Future<bool> _isEmptyDir(String path) async {
  if (path == null) {
    return false;
  }

  var directory = new Directory(path);
  if (!await directory.exists()) {
    return false;
  }

  return (await directory.list()).isEmpty;
}
