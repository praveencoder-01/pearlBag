import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class OrderService {
  static Future<void> placeOrder({
    required String userId,
    required List<Product> items,
    required double total,
    required Map<String, dynamic> address,
    required String paymentMethod,
  }) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc();

    await orderRef.set({
      'userId': userId,
      'items': items.map((p) => {
        'name': p.name,
        'price': p.price,
        'imageUrl': p.imageUrl, // ✅ STRING ONLY
        'quantity': 1,
      }).toList(),
      'address': address,
      'paymentMethod': paymentMethod,
      'total': total,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}