import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';

class Context {
  final Logger logger;
  final BeaverStore beaverStore;

  Context(this.logger, this.beaverStore);
}

class Trigger {
  final String type;
  final Map<String, String> headers;
  final Map<String, Object> data;

  Trigger(this.type, this.headers, this.data);
}
