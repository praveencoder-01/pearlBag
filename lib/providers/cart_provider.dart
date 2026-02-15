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

  CartProvider() {
    // ignore: avoid_print
    print("✅ CartProvider CREATED: ${identityHashCode(this)}");
  }

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
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('cart').doc(user.uid).get();

    // ✅ If doc not exists, DON'T clear local cart
    if (!doc.exists) return;

    final data = doc.data();

    // ✅ If data/items missing, DON'T clear local cart
    if (data == null || data['items'] == null) return;

    final List itemsList = List.from(data['items']);

    // ✅ If firestore items empty, DON'T clear local cart (prevents accidental wipe)
    if (itemsList.isEmpty) return;

    // ✅ Now it's safe to replace local state
    _items.clear();

    for (final item in itemsList) {
      _items.add(
        Product(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          price: ((item['price'] ?? 0) as num).toDouble(),
          originalPrice: ((item['originalPrice'] ?? item['price'] ?? 0) as num).toDouble(),
          category: item['category'] ?? '',
          description: (item['description'] ?? '').toString(),
          shippingPolicy: (item['shippingPolicy'] ?? '').toString(),
          returnPolicy: (item['returnPolicy'] ?? '').toString(),
          specs: Map<String, String>.from(item['specs'] ?? {}),

          images: const [],
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
              'originalPrice': p.originalPrice,
              'description': p.description,
              'shippingPolicy': p.shippingPolicy,
              'returnPolicy': p.returnPolicy,
              'specs': p.specs,

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

    final data = doc.data();
    if (data == null || data['items'] == null) return;

    final List itemsList = List.from(data['items']);

    // ✅ If firestore empty, don't wipe local cart
    if (itemsList.isEmpty) return;

    _items.clear(); // ✅ clear only after valid items found

    for (final item in itemsList) {
      _items.add(
        Product(
          id: item['id'] ?? '',
          name: item['name'] ?? '',
          price: ((item['price'] ?? 0) as num).toDouble(),
          originalPrice: ((item['originalPrice'] ?? item['price'] ?? 0) as num)
              .toDouble(),

          category: item['category'] ?? '',
          description: (item['description'] ?? '').toString(),
          shippingPolicy: (item['shippingPolicy'] ?? '').toString(),
          returnPolicy: (item['returnPolicy'] ?? '').toString(),
          specs: Map<String, String>.from(item['specs'] ?? {}),
          images: const [],
          imageUrl: item['cartImage'] ?? '',
          cartImage: item['cartImage'] ?? '',
          quantity: ((item['quantity'] ?? 1) as int),
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

// ✅ subtotal = sum(price * qty)
double get subTotal {
  double total = 0;
  for (final item in _items) {
    total += item.price * item.quantity;
  }
  return total;
}

// ✅ shipping rule: FREE above 1000 else 49
double get shippingFee {
  if (subTotal >= 1000) return 0;
  return 49;
}

// ✅ bag total = subtotal + shipping
double get bagTotal => subTotal + shippingFee;

// ✅ optional: total quantity of items (1+2+1 = 4)
int get totalItemsQty {
  int total = 0;
  for (final item in _items) {
    total += item.quantity;
  }
  return total;
}


}
