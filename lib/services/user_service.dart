import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> ensureUserDoc(User user) async {
  final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

  final snap = await ref.get();

  if (!snap.exists) {
    await ref.set({
      "email": user.email,
      "isAdmin": false, // every new user normal by default
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}