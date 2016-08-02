import './base.dart';

class UnsupportedPlatformException extends TaskException {
  UnsupportedPlatformException() : super('Unsupported platform');
}
