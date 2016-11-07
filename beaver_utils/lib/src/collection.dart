dynamic deepCopy(dynamic o) {
  if (o is Map) {
    Map map = {};
    o.forEach((key, value) {
      map[key] = deepCopy(value);
    });
    return map;
  } else if (o is List) {
    List list = [];
    o.forEach((e) => list.add(deepCopy(e)));
    return list;
  }
  return o;
}
