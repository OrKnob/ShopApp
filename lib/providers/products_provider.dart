import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  final String _token;
  final String _userId;

  ProductsProvider(this._token, this._products, this._userId);

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((item) => item.isFavorite == true).toList();
  }

  Product findById(String id) {
    return products.firstWhere((product) => id == product.id);
  }

  Future<void> fetchProducts(bool isFiltering) async {
    var url =
        'https://shop-app-639e9.firebaseio.com/products.json?auth=$_token';
    if (isFiltering) {
      url =
          'https://shop-app-639e9.firebaseio.com/products.json?auth=$_token&orderBy="userId"&equalTo="$_userId"';
    }

    try {
      var response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> productsList = [];
      if (extractedData == null) {
        return;
      }
      url =
          'https://shop-app-639e9.firebaseio.com/userData/$_userId/favoritesData.json?auth=$_token';
      response = await http.get(url);
      final _userFavoriteData = json.decode(response.body);

      extractedData.forEach((key, value) {
        productsList.add(Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            isFavorite: _userFavoriteData == null
                ? false
                : _userFavoriteData[key] ?? false,
            imageUrl: value['imageUrl']));
      });
      _products = productsList;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-639e9.firebaseio.com/products.json?auth=$_token';
    try {
      final response = await http.post(url,
          body: json.encode({
            // because data can be stored in firebase only in json format and in the form of maps
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'userId': _userId
          }));

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _products.add(newProduct);
      notifyListeners();
      print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    var _existingProductIndex = _products.indexWhere((prod) => prod.id == id);
    var _existingProduct = _products[_existingProductIndex];

    _products.remove(_existingProduct);
    notifyListeners();
    final url =
        'https://shop-app-639e9.firebaseio.com/products/$id.json?auth=$_token';
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(_existingProductIndex,
          _existingProduct); //We are rolling back the changes if an error occurs
      notifyListeners();
      throw HttpException('Product deletion failed!');
    } else {
      _existingProductIndex = null;
      _existingProduct = null;
    }
  }

  Future<void> editProduct(String productId, Product product) async {
    try {
      if (productId != null) {
        final url =
            'https://shop-app-639e9.firebaseio.com/products/$productId.json?auth=$_token';
        await http.patch(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
            }));
        final prodIndex = _products.indexWhere((prod) => prod.id == productId);
        _products[prodIndex] = product;
        notifyListeners();
      } else {
        return;
      }
    } catch (error) {
      throw error;
    }
  }
}
