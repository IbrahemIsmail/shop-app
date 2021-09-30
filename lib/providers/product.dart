import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/httpException.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  void _setFavVal(bool newVal) {
    isFavorite = newVal;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    final updateUrl = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');
    var oldIsFav = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        updateUrl,
        body: json.encode(isFavorite),
      );

      if (response.statusCode >= 400) {
        _setFavVal(oldIsFav);
        throw HttpException('Cannot update favorite');
      }
    } catch (err) {
      _setFavVal(oldIsFav);
    }
  }
}
