String extractOption(List<String> args, String option) {
  if (args.contains(option)) {
    final index = args.indexOf(option);
    args.removeAt(index);
    return args.removeAt(index);
  }
  return null;
}

bool extractFlag(List<String> args, String flag, {bool defaultsTo}) {
  if (args.contains(flag)) {
    return true;
  }
  return defaultsTo != null ? defaultsTo : false;
}
