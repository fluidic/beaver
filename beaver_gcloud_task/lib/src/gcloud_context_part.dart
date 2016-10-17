import 'dart:async';

import 'package:beaver_gcloud/beaver_gcloud.dart';
import 'package:beaver_task/beaver_task.dart';

@ContextPartClass('gcloud')
class GCloudContextPart extends ContextPart with GCloudMixin {
  GCloudContextPart();

  Future<Null> setUp(Config config) => super
      .init(config.cloudSettings['project_name'], config.cloudSettings['zone']);
  Future<Null> tearDown() async {}
}
