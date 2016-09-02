import 'package:beaver_config_store/beaver_config_store.dart';
import 'package:logging/logging.dart';

class Context {
  final Logger logger;
  final ConfigStore configStore;

  Context(this.logger, this.configStore);
}

class Trigger {
  final String type;
  final Map<String, String> headers;
  final Map<String, Object> data;

  Trigger(this.type, this.headers, this.data);
}
