import "package:test/test.dart";
import "package:beaver_task/beaver_task.dart";

void main() {
  test("--process-working-dir must be parsed.", () {
    final json =
        '{"name":"git","args":["--process-working-dir", ".", "status"]}';
    final gitTask = new Task.fromJson(json) as GitTask;
    expect(gitTask.processWorkingDir, equals('.'));
  });
  test("-C must be parsed as same as --process-working-dir.", () {
    final json =
        '{"name":"git","args":["-C", ".", "status"]}';
    final gitTask = new Task.fromJson(json) as GitTask;
    expect(gitTask.processWorkingDir, equals('.'));
  });
  test("The trailing options that appear after non-option arguments must not be parsed.", () {
    final json =
        '{"name":"git","args":["--process-working-dir", ".", "push", "--force"]}';
    final gitTask = new Task.fromJson(json) as GitTask;
    expect(gitTask.processWorkingDir, equals("."));
    expect(gitTask.args, equals(["push", "--force"]));
  });
}
