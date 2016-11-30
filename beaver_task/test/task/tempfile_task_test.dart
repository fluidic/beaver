import "package:test/test.dart";
import "package:beaver_task/beaver_task.dart";

void main() {
  test("Tempfile should be able to be constructed from JSON string.", () {
    final json = '{"name":"tempfile","args":[]}';
    final task = new Task.fromJson(json);
    expect(task.runtimeType, equals(TempfileTask));
  });
  test("--prefix and --suffix must be parsed.", () {
    final json =
        '{"name":"tempfile","args":["--prefix", "a", "--suffix", "b"]}';
    final tempfileTask = new Task.fromJson(json) as TempfileTask;
    expect(tempfileTask.prefix, equals("a"));
    expect(tempfileTask.suffix, equals("b"));
  });
}
