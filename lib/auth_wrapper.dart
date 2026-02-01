import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_website/admin/admin_dashboard.dart';
// import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/screens/home_screen.dart';
import 'package:food_website/screens/login_screen.dart';
// import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
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
      .collection('admin')
      .doc(user.uid)
      .get(),
  builder: (context, adminSnap) {

    // Step B: safe load after first frame
    

    if (adminSnap.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // check if mounted to avoid errors
      if (context.mounted) {
        // context.read<CartProvider>().loadCartFromFirestore();
      }
    });

    if (adminSnap.data != null && adminSnap.data!.exists) {
      return const AdminDashboard();
    } else {
      return const HomeScreen();
    }
  },
);
      },
    );
  }
}
