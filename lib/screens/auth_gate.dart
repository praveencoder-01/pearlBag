import 'package:flutter/material.dart';
import 'package:food_website/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return auth.isLoggedIn
        ? const HomeScreen()
        : const LoginScreen();
  }
}
