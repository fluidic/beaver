import './base.dart';

class NoneLogger extends Logger {
  const NoneLogger();

  @override
  void log(LogLevel logLevel, message) {}
}

class ConsoleLogger extends Logger {
  @override
  void log(LogLevel logLevel, message) {
    print('${logLevel}: ${message}');
  }
}

class MemoryLogger extends Logger {
  final Logger _parent;

  final StringBuffer _buffer = new StringBuffer();

  MemoryLogger(this._parent);

  @override
  void log(LogLevel logLevel, message) {
    _parent.log(logLevel, message);
    _buffer.writeln('${logLevel}: ${message}');
  }

  @override
  String toString() => _buffer.toString();
}
