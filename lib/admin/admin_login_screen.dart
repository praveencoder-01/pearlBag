// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:food_website/admin/admin_dashboard.dart';


// class AdminLoginScreen extends StatefulWidget {
//   const AdminLoginScreen({super.key});

//   @override
//   State<AdminLoginScreen> createState() => _AdminLoginScreenState();
// }

// class _AdminLoginScreenState extends State<AdminLoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> adminLogin() async {
//     setState(() => isLoading = true);

//     try {
//       // 1️⃣ Firebase Auth login
//       UserCredential userCredential =
//           await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       User user = userCredential.user!;

//       // 2️⃣ Firestore admin check
//       DocumentSnapshot adminDoc = await FirebaseFirestore.instance
//           .collection('admins')
//           .doc(user.uid)
//           .get();

//       // 3️⃣ Result
//       if (adminDoc.exists) {
//         // ✅ ADMIN
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AdminDashboard(),
//           ),
//         );
//       } else {
//         // ❌ NOT ADMIN
//         await FirebaseAuth.instance.signOut();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("You are not an admin"),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           width: 400,
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Admin Login",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),

//               TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//               ),
//               const SizedBox(height: 10),

//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//               ),
//               const SizedBox(height: 20),

//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: adminLogin,
//                       child: const Text("Login"),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
