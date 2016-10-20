import 'dart:convert';
import 'dart:mirrors';

newInstance(String constructorName, ClassMirror cm, List args) =>
    cm.newInstance(new Symbol(constructorName), args).reflectee;

List<ClassMirror> queryClassesByAnnotation(ClassMirror annotation) {
  List<ClassMirror> results = [];
  MirrorSystem mirrorSystem = currentMirrorSystem();
  mirrorSystem.libraries.forEach((_, l) {
    l.declarations.forEach((_, d) {
      if (d is ClassMirror) {
        ClassMirror cm = d;
        cm.metadata.forEach((md) {
          InstanceMirror metadata = md;
          if (metadata.type == annotation) {
            results.add(cm);
          }
        });
      }
    });
  });
  return results;
}

class EnumCodec<T> extends Codec<String, T> {
  @override
  Converter<T, String> get decoder => new EnumToString<T>();

  @override
  Converter<String, T> get encoder => new EnumFromString<T>();
}

class EnumFromString<T> extends Converter<String, T> {
  @override
  T convert(String input) {
    ClassMirror cm = reflectType(T) as ClassMirror;
    return cm.getField(#values).reflectee.firstWhere((e) =>
        e.toString().split('.')[1].toUpperCase() == input.toUpperCase()) as T;
  }
}

class EnumToString<S> extends Converter<S, String> {
  @override
  String convert(S input) => input.toString().split('.')[1];
}
