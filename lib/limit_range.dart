import 'dart:math' as math;

class LimitRange<T extends num> {
  final T begin;
  final T end;

  T _value;
  T get value => _value;
  set value(T newValue) {
    if (newValue < begin) {
      _value = begin;
    } else if (newValue > end) {
      _value = end;
    } else {
      _value = newValue;
    }
  }

  LimitRange({required this.begin, required this.end}) : _value = begin;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LimitRange<double> &&
        other.begin == begin &&
        other.end == end &&
        other._value == _value;
  }

  @override
  int get hashCode => begin.hashCode ^ end.hashCode ^ _value.hashCode;
}
