import "package:test/test.dart";
import "package:beaver_task/beaver_task.dart";

void main() {
  test("TouchTask should be able to be constructed from JSON string.", () {
    final json = '{"name":"touch","args":["arg1"]}';
    final task = new Task.fromJson(json);
    expect(task.runtimeType, equals(TouchTask));
  });
  test("--[no-]create flag must be parsed.", () {
    final json = '{"name":"touch","args":["--create", "arg1"]}';
    final touchTask = new Task.fromJson(json) as TouchTask;
    expect(touchTask.create, equals(true));
    expect(touchTask.paths.first, equals("arg1"));
  });
}
