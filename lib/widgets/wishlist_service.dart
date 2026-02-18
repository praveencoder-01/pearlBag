import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> get _wishlistRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('wishlist');

  static Future<bool> isWishlisted(String productId) async {
    final snap = await _wishlistRef.doc(productId).get();
    return snap.exists;
  }

  static Future<void> add(String productId) async {
    await _wishlistRef.doc(productId).set({
      "productId": productId,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> remove(String productId) async {
    await _wishlistRef.doc(productId).delete();
  }

  static Stream<List<String>> wishlistIdsStream() {
    return _wishlistRef
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => d.id).toList(),
        ); // docId = productId
  }
}
