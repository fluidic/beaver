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
