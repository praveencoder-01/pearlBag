import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_shell.dart';
import 'package:food_website/main_shell.dart';
import 'package:food_website/screens/login_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
          
        }

        final user = snapshot.data!;

      return FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get(),
  builder: (context, adminSnap) {
    if (adminSnap.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (adminSnap.hasError) {
      return Scaffold(
        body: Center(
          child: Text("Role check failed: ${adminSnap.error}"),
        ),
      );
    }

    final data = adminSnap.data?.data() as Map<String, dynamic>?;
    final isAdmin = data?['isAdmin'] == true;

    return isAdmin
        ? const PearlAdminShell(current: "dashboard")
        : const MainShell();
  },
);
      },
    );
  }
}
