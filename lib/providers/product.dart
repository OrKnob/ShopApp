import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {this.id,
      this.title,
      this.description,
      this.price,
      this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavorite(
      Product product, String token, String userId) async {
    bool favoriteStatus = !product.isFavorite;
    product.isFavorite = favoriteStatus;
    notifyListeners();
    final productId = product.id;
    final url =
        'https://shop-app-639e9.firebaseio.com/userData/$userId/favoritesData/$productId.json?auth=$token';
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        favoriteStatus = !product.isFavorite;
        product.isFavorite = favoriteStatus;
        notifyListeners();
      }
    } catch (error) {
      favoriteStatus = !product.isFavorite;
      product.isFavorite = favoriteStatus;
      notifyListeners();
    }
  }
}
