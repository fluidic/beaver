import 'package:beaver_task/beaver_task.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

class TestContext extends Context {
  @override
  Config get config => null;

  @override
  Logger get logger => null;

  @override
  ContextPart getPart(String name) => null;
}

void main() {
  group('Combinators Test', () {
    test('seq', () async {
      List<int> list = [];
      final tasks = new Iterable.generate(5, (i) {
        return new Task.fromFunc((context) {
          list.add(i);
        });
      });
      await seq(tasks).execute(new TestContext());
      expect(list, orderedEquals([0, 1, 2, 3, 4]));
    });
    // FIXME: How to test par?
  });
}
