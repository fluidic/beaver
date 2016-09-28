import 'dart:async';

import './top_level.dart';

Future<GSUtilProcessResult> removeBucket(Uri uri) =>
    runGSUtil(['rb', uri.toString()]);

