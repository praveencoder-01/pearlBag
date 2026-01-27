import 'package:flutter/material.dart';

class DrawerProvider extends ChangeNotifier {
  bool _leftOpen = false;
  bool _rightOpen = false;
  
  bool get isAnyOpen => isLeftOpen || isRightOpen;

  bool get isLeftOpen => _leftOpen;
  bool get isRightOpen => _rightOpen;

  void openLeft() {
    _leftOpen = true;
    _rightOpen = false;
    notifyListeners();
  }

  void openRight() {
    _rightOpen = true;
    _leftOpen = false;
    notifyListeners();
  }

  void closeAll() {
    _leftOpen = false;
    _rightOpen = false;
    notifyListeners();
  }
}
