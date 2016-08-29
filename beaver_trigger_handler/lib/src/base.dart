import 'package:logging/logging.dart';
import 'package:beaver_store/beaver_store.dart';

class Context {
  final Logger logger;
  final ProjectStore projectStore;

  Context(this.logger, this.projectStore);
}
