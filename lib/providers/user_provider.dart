import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool loading = false;

  String name = '';
  String phone = '';
  Map<String, String> address = {
    'street': '',
    'city': '',
    'state': '',
    'pincode': '',
    'country': 'India',
  };

  

  bool get hasAddress =>
      (address['street'] ?? '').trim().isNotEmpty &&
      (address['city'] ?? '').trim().isNotEmpty &&
      (address['state'] ?? '').trim().isNotEmpty &&
      (address['pincode'] ?? '').trim().isNotEmpty &&
      phone.trim().isNotEmpty;

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    loading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data == null) return;

      name = (data['name'] ?? '').toString();
      phone = (data['phone'] ?? '').toString();

      final a = (data['address'] as Map?) ?? {};
      address = {
        'street': (a['street'] ?? '').toString(),
        'city': (a['city'] ?? '').toString(),
        'state': (a['state'] ?? '').toString(),
        'pincode': (a['pincode'] ?? '').toString(),
        'country': (a['country'] ?? 'India').toString(),
      };
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveAddress({
    required String name,
    required String phone,
    required String street,
    required String city,
    required String state,
    required String pincode,
    String country = "India",
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'phone': phone,
      'address': {
        'street': street,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ✅ update local cache (so UI updates instantly)
    this.name = name;
    this.phone = phone;
    address = {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
    notifyListeners();
  }
}
