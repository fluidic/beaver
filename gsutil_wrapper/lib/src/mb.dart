import 'dart:async';

import './top_level.dart';

enum StorageClass { standard, durableReducedAvailability, nearline }

String _storageClassToString(StorageClass clazz) {
  switch (clazz) {
    case StorageClass.standard:
      return 'standard';
    case StorageClass.nearline:
      return 'nearline';
    case StorageClass.durableReducedAvailability:
      return 'dra';
  }
  return 'standard';
}

Future<GSUtilProcessResult> createBucket(
        StorageClass clazz, String location, String projectId, Uri uri) =>
    runGSUtil([
      'mb',
      '-c',
      _storageClassToString(clazz),
      '-l',
      location,
      '-p',
      projectId,
      uri.toString()
    ]);
