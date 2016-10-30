import "package:test/test.dart";
import "package:beaver_task/beaver_task.dart";

void main() {
  test("DeleteTask should be able to be constructed from JSON string.", () {
    final json = '{"name":"delete","args":[]}';
    final task = new Task.fromJson(json);
    expect(task.runtimeType, equals(DeleteTask));
  });
  test("--[no-]force flag must be parsed.", () {
    final json = '{"name":"delete","args":["--no-force", "arg1"]}';
    final deleteTask = new Task.fromJson(json) as DeleteTask;
    expect(deleteTask.force, equals(false));
    expect(deleteTask.paths.first, equals("arg1"));
  });
  test("--[no-]recursive flag must be parsed.", () {
    final json = '{"name":"delete","args":["--no-recursive", "arg1"]}';
    final deleteTask = new Task.fromJson(json) as DeleteTask;
    expect(deleteTask.recursive, equals(false));
    expect(deleteTask.paths.first, equals("arg1"));
  });
  test("--force and --recursive flag must be true if it is not presented.", () {
    final json = '{"name":"delete","args":["arg1"]}';
    final deleteTask = new Task.fromJson(json) as DeleteTask;
    expect(deleteTask.force, equals(true));
    expect(deleteTask.recursive, equals(true));
  });
}
