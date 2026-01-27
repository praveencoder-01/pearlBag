import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;

  void login(String email, String password) {
    // Dummy validation (accept anything non-empty)
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _email = email;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
  }
}
