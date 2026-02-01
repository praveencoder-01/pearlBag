import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;
  int get itemCount => _items.length;

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔥 ADD TO CART
  Future<void> addToCart(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);

    if (index != -1) {
      _items[index].quantity += product.quantity;
    } else {
      _items.add(product.copyWith(quantity: product.quantity));
    }

    notifyListeners();
    await _saveCartToFirestore();
  }

  Future<void> syncFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .doc(uid)
        .collection('items')
        .get();

    _items.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      _items.add(
        Product(
          id: doc.id,
          name: data['name'],
          price: (data['price'] as num).toDouble(),
          originalPrice: (data['price'] as num).toDouble(),
          quantity: data['quantity'],
          cartImage: data['cartImage'],
          category: data['category'],
          description: '',
          images: [],
          imageUrl: data['cartImage'],
          infoSection: ProductInfoSectionData(
            title: '',
            description: '',
            image: '',
          ),
        ),
      );
    }

    notifyListeners();
  }

  // 🔥 REMOVE
  Future<void> removeFromCart(Product product) async {
    _items.removeWhere((p) => p.id == product.id);
    notifyListeners();
    await _saveCartToFirestore();
  }

  // 🔥 UPDATE QTY
  Future<void> updateQuantity(Product product, int qty) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index == -1) return;

    _items[index].quantity = qty;
    notifyListeners();
    await _saveCartToFirestore();
  }

  // 🔥 SAVE CART
  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('cart').doc(user.uid).set({
      'items': _items
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'price': p.price,
              'quantity': p.quantity,
              'cartImage': p.cartImage,
              'category': p.category,
            },
          )
          .toList(),
    }, SetOptions(merge: true));
  }

  // 🔥 CLEAR CART AFTER ORDER
  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('cart').doc(user.uid).set({
        'items': [],
      }, SetOptions(merge: true)); // safe overwrite
    }
  }

  // 🔥 LOAD CART (MOST IMPORTANT)
  Future<void> loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('cart').doc(user.uid).get();

    if (!doc.exists) return;

    _items.clear();

    final data = doc.data();
    if (data == null || data['items'] == null) return;

    for (var item in data['items']) {
      _items.add(
        Product(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
          originalPrice: (item['price'] ?? 0).toDouble(),
          category: item['category'] ?? '',
          description: '',
          images: [],
          imageUrl: item['cartImage'] ?? '',
          cartImage: item['cartImage'] ?? '',
          quantity: item['quantity'] ?? 1,
          infoSection: ProductInfoSectionData(
            title: '',
            description: '',
            image: '',
          ),
        ),
      );
    }

    notifyListeners();
  }
}
