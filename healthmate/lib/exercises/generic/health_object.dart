import 'package:flutter/foundation.dart';

class HealthObject<T> {
  T content;

  HealthObject(this.content);

  T getContent() {
    return content;
  }

  void showInfo() {
    debugPrint('Gia tri: $content');
  }
}
