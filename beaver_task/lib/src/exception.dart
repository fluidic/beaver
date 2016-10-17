import 'dart:io';

import './base.dart';

class UnsupportedPlatformException extends TaskException {
  UnsupportedPlatformException()
      : super('${Platform.operatingSystem} is not supported');
}
