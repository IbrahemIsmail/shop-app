import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/httpException.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String authToken;
  final String userId;

  Products(this._items, this.authToken, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    final favUrl = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? data = json.decode(response.body);
      final List<Product> products = [];
      if (data == null || data['error'] != null) return;
      final favRes = await http.get(favUrl);
      final favData = json.decode(favRes.body);
      data.forEach((pId, pData) {
        products.add(
          Product(
            id: pId,
            title: pData['title'],
            description: pData['description'],
            imageUrl: pData['imageUrl'],
            price: pData['price'],
            isFavorite: favData == null ? false : favData[pId] ?? false,
          ),
        );
      });
      _items = products;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product p) async {
    final url = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': p.title,
            'description': p.description,
            'imageUrl': p.imageUrl,
            'price': p.price,
            'isFavorite': p.isFavorite,
            'userId': userId,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: p.title,
        description: p.description,
        imageUrl: p.imageUrl,
        price: p.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product p) async {
    final pI = _items.indexWhere((p) => p.id == id);
    if (pI >= 0) {
      final updateUrl = Uri.parse(
          'https://flutter-db-thingy-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      http.patch(
        updateUrl,
        body: json.encode({
          'title': p.title,
          'description': p.description,
          'imageUrl': p.imageUrl,
          'price': p.price,
        }),
      );
      _items[pI] = p;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final deleteUrl = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final pI = _items.indexWhere((p) => p.id == id);
    Product? p = _items[pI];
    _items.removeWhere((p) => p.id == id);
    notifyListeners();

    final response = await http.delete(deleteUrl);
    if (response.statusCode >= 400) {
      _items.insert(pI, p);
      notifyListeners();
      throw HttpException('Could not delete product');
    }

    p = null;
    // notifyListeners();
  }
}
