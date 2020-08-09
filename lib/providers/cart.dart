import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({this.id, this.title, this.quantity, this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};
  int itemsQuantity = 0;

  Map<String, CartItem> get items {
    return {..._cartItems};
  }

  double get totalAmount {
    double _totalAmount = 0;
    _cartItems.forEach((key, cartItem) {
      _totalAmount = _totalAmount + cartItem.price * cartItem.quantity;
    });
    return _totalAmount;
  }

  void addItem(String id, String title, double price) {
    if (_cartItems.containsKey(id)) {
      _cartItems.update(
          id,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1));
      notifyListeners();
    } else {
      _cartItems.putIfAbsent(
          id,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              quantity: 1));
      notifyListeners();
    }
    itemsQuantity = itemsQuantity + 1;
  }

  void removeSingleItem(String productId) {
    if (!_cartItems.containsKey(productId)) {
      return;
    } else {
      if (_cartItems[productId].quantity > 1) {
        _cartItems.update(
            productId,
            (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1));
        itemsQuantity = itemsQuantity - 1;
        notifyListeners();
      } else {
        _cartItems.remove(productId);
        itemsQuantity = itemsQuantity - 1;
        notifyListeners();
      }
    }
  }

  int get countCartItems {
    return itemsQuantity;
  }

  int get individualQuantity {
    return _cartItems.length;
  }

  void removeItem(String id) {
    _cartItems.forEach((key, cartItem) {
      if (key == id) {
        itemsQuantity = itemsQuantity - cartItem.quantity;
      }
    });
    _cartItems.remove(id);
    notifyListeners();
  }

  void clear() {
    _cartItems = {};
    itemsQuantity = 0;
    notifyListeners();
  }
}
