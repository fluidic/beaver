/// Returns the concatentation of the input iterables.
///
/// The returned iterable is a lazily-evaluated view on the input iterables.
Iterable/*<T>*/ concat/*<T>*/(Iterable<Iterable/*<T>*/> iterables) => iterables.expand((x) => x);
