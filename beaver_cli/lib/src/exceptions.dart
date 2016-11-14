/// An exception class for exceptions that are intended to be seen by the user.
///
/// These exceptions won't have any debugging information printed when they're
/// thrown.
class ApplicationException implements Exception {
  final String message;

  ApplicationException(this.message);

  @override
  String toString() => message;
}
