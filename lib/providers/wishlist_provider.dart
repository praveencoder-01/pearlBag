import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  StreamSubscription? _sub;

  // ✅ All wishlisted product ids
  Set<String> _ids = {};
  Set<String> get ids => _ids;

  bool isWishlisted(String productId) => _ids.contains(productId);

  WishlistProvider() {
    _listen();
  }

  void _listen() {
    final user = _auth.currentUser;
    if (user == null) {
      _ids = {};
      notifyListeners();
      return;
    }

    _sub?.cancel();
    _sub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .snapshots()
        .listen((snap) {
      _ids = snap.docs.map((d) => d.id).toSet(); // docId = productId
      notifyListeners();
    });
  }

  // call after login/logout if needed
  void refreshAfterAuthChange() => _listen();

  Future<void> add(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // ✅ instant UI update (optimistic)
    _ids = {..._ids, productId};
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .set({
      "productId": productId,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // ✅ instant UI update (optimistic)
    _ids = {..._ids}..remove(productId);
    notifyListeners();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  Future<void> toggle(String productId) async {
    if (isWishlisted(productId)) {
      await remove(productId);
    } else {
      await add(productId);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}