import 'dart:async';

// Retries [callback] until it successfully returns a result without throwing an
// exception. Pause between trials by [interval].
Future/*<T>*/ retry/*<T>*/(
    int n, Duration interval, Future/*<T>*/ callback()) async {
  var result;
  while (n > 0) {
    n--;
    try {
      result = await callback();
      break;
    } catch (error) {
      if (n == 0) throw error;
    }
    await new Future.delayed(interval);
  }
  return result;
}
