
import 'package:flutter/foundation.dart';

class UnreadMessageNotifier extends ValueNotifier<int> {
  UnreadMessageNotifier() : super(0);

  void setCount(int count) => value = count;
  void increment() => value++;
  void decrement() {
    if (value > 0) value--;
  }
}
