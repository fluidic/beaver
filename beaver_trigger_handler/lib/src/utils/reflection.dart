import 'dart:mirrors';

// FIXME: This util is duplicated with beaver_task's reflection.

Map<String, ClassMirror> loadClassMapByAnnotation(Type annotationClassType) {
  final taskClassMap = {};
  final cms = _queryClassesByAnnotation(reflectClass(annotationClassType));
  for (final cm in cms) {
    cm.metadata.forEach((md) {
      InstanceMirror metadata = md as InstanceMirror;
      String name = metadata.getField(#name).reflectee;
      taskClassMap[name] = cm;
    });
  }
  return taskClassMap;
}

newInstance(ClassMirror cm, List args) =>
    cm.newInstance(new Symbol(''), args).reflectee;

List<ClassMirror> _queryClassesByAnnotation(ClassMirror annotation) {
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
