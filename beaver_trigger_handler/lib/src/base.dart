import 'package:logging/logging.dart';
import 'package:beaver_store/beaver_store.dart';

class Context {
  final Logger logger;
  final ProjectStore projectStore;

  Context(this.logger, this.projectStore);
}

class Trigger {
  final String type;
  final Map<String, String> headers;
  final Map<String, Object> data;

  Trigger(this.type, this.headers, this.data);
}
