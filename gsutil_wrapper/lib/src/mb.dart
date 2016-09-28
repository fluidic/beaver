import 'dart:async';

import './top_level.dart';

enum StorageClass { Standard, DurableReducedAvailability, Nearline }

String _storageClassToString(StorageClass clazz) {
  switch (clazz) {
    case StorageClass.Standard:
      return 'standard';
    case StorageClass.Nearline:
      return 'nearline';
    case StorageClass.DurableReducedAvailability:
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
