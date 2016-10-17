import 'dart:async';

import 'package:logging/logging.dart';

// An implementation of [Logger] that delegates all methods to another [Logger].
abstract class DelegatingLogger implements Logger {
  Logger get delegate;

  @override
  String get name => delegate.name;

  @override
  String get fullName => delegate.fullName;

  @override
  Logger get parent => delegate.parent;

  @override
  Level get level => delegate.level;

  @override
  Map<String, Logger> get children => delegate.children;

  @override
  Stream<LogRecord> get onRecord => delegate.onRecord;

  @override
  void set level(Level value) {
    delegate.level = value;
  }

  @override
  bool isLoggable(Level value) => delegate.isLoggable(value);

  @override
  void fine(message, [Object error, StackTrace stackTrace]) {
    delegate.fine(message, error, stackTrace);
  }

  @override
  void warning(message, [Object error, StackTrace stackTrace]) {
    delegate.warning(message, error, stackTrace);
  }

  @override
  void finer(message, [Object error, StackTrace stackTrace]) {
    delegate.finer(message, error, stackTrace);
  }

  @override
  void severe(message, [Object error, StackTrace stackTrace]) {
    delegate.severe(message, error, stackTrace);
  }

  @override
  void config(message, [Object error, StackTrace stackTrace]) {
    delegate.config(message, error, stackTrace);
  }

  @override
  void log(Level logLevel, message,
      [Object error, StackTrace stackTrace, Zone zone]) {
    delegate.log(message, stackTrace, zone);
  }

  @override
  void info(message, [Object error, StackTrace stackTrace]) {
    delegate.info(message, error, stackTrace);
  }

  @override
  void finest(message, [Object error, StackTrace stackTrace]) {
    delegate.finest(message, error, stackTrace);
  }

  @override
  void shout(message, [Object error, StackTrace stackTrace]) {
    delegate.shout(message, error, stackTrace);
  }

  @override
  void clearListeners() {
    delegate.clearListeners();
  }
}

/// [BeaverLogger] records all the log message into the internal string buffer.
class BeaverLogger extends DelegatingLogger {
  final StringBuffer _buffer = new StringBuffer();

  final Logger _delegate = new Logger('BeaverLogger');

  @override
  Logger get delegate => _delegate;

  BeaverLogger() {
    _delegate.onRecord.listen((LogRecord rec) {
      _buffer.writeln('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }

  @override
  String toString() => _buffer.toString();
}

