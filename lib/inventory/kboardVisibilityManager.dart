import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardVisibilityManager {
  late KeyboardVisibilityController keyboardVisibilityController;
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  bool visibleKeyboard = false;

  KeyboardVisibilityManager() {
    checkKeyboardVisibility();
  }

  void checkKeyboardVisibility() {
    keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilitySubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      visibleKeyboard = visible;
    });
  }

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void dispose() {
    keyboardVisibilitySubscription.cancel();
  }
}
