import 'package:beaver_cli/beaver_cli.dart' as beaver_cli;

void main(List<String> arguments) {
  final runner = beaver_cli.getRunner();
  runner.run(arguments);
}

