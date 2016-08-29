import 'dart:mirrors';

newInstance(ClassMirror cm, List args) => cm.newInstance(new Symbol(''), args).reflectee;

List<ClassMirror> queryClassesByAnnotation(ClassMirror annotation) {
  final results = [];
  MirrorSystem mirrorSystem = currentMirrorSystem();
  mirrorSystem.libraries.forEach((_, l) {
    l.declarations.forEach((_, d) {
      if (d is ClassMirror) {
        ClassMirror cm = d as ClassMirror;
        cm.metadata.forEach((md) {
          InstanceMirror metadata = md as InstanceMirror;
          if (metadata.type == annotation) {
            results.add(cm);
          }
        });
      }
    });
  });
  return results;
}
