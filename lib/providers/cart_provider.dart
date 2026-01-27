import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice =>
    _items.fold(0, (sum, item) => sum + item.price);


  void addToCart(Product product) {
    _items.add(product);
    notifyListeners(); // 🔥 updates UI
  }

  void removeFromCart(Product product) {
    _items.remove(product);
    notifyListeners();
  }
}
