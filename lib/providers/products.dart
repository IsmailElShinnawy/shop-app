import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavoritesOnly = false;

  final authToken;
  final userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly)
    return [..._items];
  }

  List<Product> get favorites {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-app-73929-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final favUrl = Uri.parse(
          'https://shop-app-73929-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-73929-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }

    // return http
    //     .post(
    //   url,
    //   body: json.encode({
    //     'title': product.title,
    //     'description': product.description,
    //     'imageUrl': product.imageUrl,
    //     'price': product.price,
    //     'isFavorite': product.isFavorite
    //   }),
    // )
    //     .then((response) {
    //   final newProduct = Product(
    //     description: product.description,
    //     imageUrl: product.imageUrl,
    //     price: product.price,
    //     title: product.title,
    //     id: json.decode(response.body)['name'],
    //   );
    //   _items.add(newProduct);
    //   notifyListeners();
    // }).catchError((err) {
    //   throw err;
    // });
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIdx = _items.indexWhere((item) => item.id == id);
    if (productIdx >= 0) {
      final url = Uri.parse(
          'https://shop-app-73929-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
        }),
      );
      _items[productIdx] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-73929-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex = _items.indexWhere((item) => item.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  // void setShowFavoritesOnly(bool showFavoritesOnly) {
  //   _showFavoritesOnly = showFavoritesOnly;
  //   notifyListeners();
  // }
}
