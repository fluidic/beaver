import 'dart:io';

import './util.dart';

void _printToStream(IOSink sink, Entry entry, {bool showLabel}) {
  bool firstLine = true;
  for (var line in entry.lines) {
    if (showLabel) {
      if (firstLine) {
        sink.write('${entry.level.name}: ');
      } else {
        sink.write('    | ');
      }
    }

    sink.writeln(line);

    firstLine = false;
  }
}

void _logToStream(IOSink sink, Entry entry, {bool showLabel}) {
  _printToStream(sink, entry, showLabel: showLabel);
}

/// Log function that prints the message to stdout with the level name.
void _logToStdoutWithLabel(Entry entry) {
  _logToStream(stdout, entry, showLabel: true);
}

/// Log function that prints the message to stderr with the level name.
void _logToStderrWithLabel(Entry entry) {
  _logToStream(stderr, entry, showLabel: true);
}

/// Log function that prints the message to stdout.
void _logToStdout(Entry entry) {
  _logToStream(stdout, entry, showLabel: false);
}

/// Log function that prints the message to stderr.
void _logToStderr(Entry entry) {
  _logToStream(stderr, entry, showLabel: false);
}

/// The current logging verbosity.
Verbosity verbosity = Verbosity.normal;

/// An enum type to control which log levels are displayed and how they are
/// displayed.
class Verbosity {
  /// Silence all logging.
  static const none = const Verbosity._("none", const {
    Level.error: null,
    Level.warning: null,
    Level.message: null,
    Level.io: null,
    Level.fine: null
  });

  /// Shows only errors.
  static const error = const Verbosity._("error", const {
    Level.error: _logToStderr,
    Level.warning: null,
    Level.message: null,
    Level.io: null,
    Level.fine: null
  });

  /// Shows only errors and warnings.
  static const warning = const Verbosity._("warning", const {
    Level.error: _logToStderr,
    Level.warning: _logToStderr,
    Level.message: null,
    Level.io: null,
    Level.fine: null
  });

  /// The default verbosity which shows errors, warnings, and messages.
  static const normal = const Verbosity._("normal", const {
    Level.error: _logToStderr,
    Level.warning: _logToStderr,
    Level.message: _logToStdout,
    Level.io: null,
    Level.fine: null
  });

  /// Shows errors, warnings, messages, and IO event logs.
  static const io = const Verbosity._("io", const {
    Level.error: _logToStderrWithLabel,
    Level.warning: _logToStderrWithLabel,
    Level.message: _logToStdoutWithLabel,
    Level.io: _logToStderrWithLabel,
    Level.fine: null
  });

  /// Shows all logs.
  static const all = const Verbosity._("all", const {
    Level.error: _logToStderrWithLabel,
    Level.warning: _logToStderrWithLabel,
    Level.message: _logToStdoutWithLabel,
    Level.io: _logToStderrWithLabel,
    Level.fine: _logToStderrWithLabel
  });

  const Verbosity._(this.name, this._loggers);
  final String name;
  final Map<Level, _LogFn> _loggers;

  /// Returns whether or not logs at [level] will be printed.
  bool isLevelVisible(Level level) => _loggers[level] != null;

  @override
  String toString() => name;
}

typedef void _LogFn(Entry entry);

/// An enum type for defining the different logging levels a given message can
/// be associated with.
///
/// By default, [error] and [warning] messages are printed to sterr. [message]
/// messages are printed to stdout, and others are ignored.
class Level {
  /// An error occurred and an operation could not be completed.
  ///
  /// Usually shown to the user on stderr.
  static const error = const Level._("ERR ");

  /// Something unexpected happened, but the program was able to continue,
  /// though possibly in a degraded fashion.
  static const warning = const Level._("WARN");

  /// A message intended specifically to be shown to the user.
  static const message = const Level._("MSG ");

  /// Some interaction with the external world occurred, such as a network
  /// operation, process spawning, or file IO.
  static const io = const Level._("IO  ");

  /// Fine-grained and verbose additional information.
  ///
  /// Used to provide program state context for other logs (such as what pub
  /// was doing when an IO operation occurred) or just more detail for an
  /// operation.
  static const fine = const Level._("FINE");

  const Level._(this.name);
  final String name;

  @override
  String toString() => name;
}

/// A single log entry.
class Entry {
  final Level level;
  final List<String> lines;

  Entry(this.level, this.lines);
}

/// Logs [message] at [Level.warning].
void warning(message) => write(Level.warning, message);

/// Logs [message] at [Level.message].
void message(message) => write(Level.message, message);

/// Logs [message] at [Level.io].
void io(message) => write(Level.io, message);

/// Logs [message] at [Level.fine].
void fine(message) => write(Level.fine, message);

/// Logs [message] at [level].
void write(Level level, message) {
  message = message.toString();
  var lines = splitLines(message);

  // Discard a trailing newline. This is useful since StringBuffers often end
  // up with an extra newline at the end from using [writeln].
  if (lines.isNotEmpty && lines.last == "") {
    lines.removeLast();
  }

  var entry = new Entry(level, lines);

  var logFn = verbosity._loggers[level];
  if (logFn != null) logFn(entry);
}
