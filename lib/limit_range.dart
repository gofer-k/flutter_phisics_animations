class LimitRange<T> {
  final T _begin;
  final T _end;
  T value;

  LimitRange({required this._begin, required this._end}),

  T get begin => _begin;
  T get end => _end;
  T get value => _value;
  set value(T newValue) {
    if (newValue < begin || newValue > end) {
      throw ArgumentError('Value must be between $begin and $end');
    }
    _value = newValue;
}