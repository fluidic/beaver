/// Serializes [node] into a String and returns it.
String toYamlString(node) {
  var sb = new StringBuffer();
  writeYamlString(node, sb);
  return sb.toString();
}

/// Serializes [node] into a String and writes it to the [sink].
void writeYamlString(node, StringSink sink) {
  _writeYamlString(node, 0, sink, true);
}

void _writeYamlString(node, int indent, StringSink ss, bool isTopLevel) {
  if (node is Map) {
    _mapToYamlString(node, indent, ss, isTopLevel);
  } else if (node is Iterable) {
    _listToYamlString(node, indent, ss, isTopLevel);
  } else if (node is String) {
    ss..writeln('"${_escapeString(node)}"');
  } else if (node is double) {
    ss.writeln("!!float $node");
  } else {
    ss.writeln(node);
  }
}

String _escapeString(String s) =>
    s.replaceAll('"', r'\"').replaceAll("\n", r"\n");

void _mapToYamlString(Map node, int indent, StringSink ss, bool isTopLevel) {
  if (!isTopLevel) {
    ss.writeln();
    indent += 2;
  }

  final keys = _sortKeys(node);

  keys.forEach((k) {
    final v = node[k];
    _writeIndent(indent, ss);
    ss..write(k)..write(': ');
    _writeYamlString(v, indent, ss, false);
  });
}

Iterable<String> _sortKeys(Map m) {
  List<String> simple = [];
  List<String> maps = [];
  List<String> other = [];

  m.forEach((k, v) {
    if (v is String) {
      simple.add(k);
    } else if (v is Map) {
      maps.add(k);
    } else {
      other.add(k);
    }
  });

  return concat([simple..sort(), maps..sort(), other..sort()]);
}

void _listToYamlString(
    Iterable node, int indent, StringSink ss, bool isTopLevel) {
  if (!isTopLevel) {
    ss.writeln();
    indent += 2;
  }

  node.forEach((v) {
    _writeIndent(indent, ss);
    ss.write('- ');
    _writeYamlString(v, indent, ss, false);
  });
}

void _writeIndent(int indent, StringSink ss) => ss.write(' ' * indent);

/// Returns the concatentation of the input iterables.
///
/// The returned iterable is a lazily-evaluated view on the input iterables.
Iterable/*<T>*/ concat/*<T>*/(Iterable<Iterable/*<T>*/> iterables) => iterables.expand((x) => x);
