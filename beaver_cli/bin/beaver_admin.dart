import 'package:beaver_cli/beaver_admin_cli.dart' as beaver_admin_cli;

void main(List<String> arguments) {
  final runner = beaver_admin_cli.getRunner();
  runner.run(arguments);
}
