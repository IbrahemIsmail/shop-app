import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(
    this.authToken,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final List<OrderItem> fetchedOrders = [];
      final Map<String, dynamic>? data = json.decode(response.body);
      if (data == null) return;
      data.forEach((oId, val) {
        fetchedOrders.add(
          OrderItem(
            id: oId,
            amount: val['amount'],
            products: (val['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(val['dateTime']),
          ),
        );
      });
      _orders = fetchedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse(
        'https://flutter-db-thingy-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final timeStamp = DateTime.now();
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': products
              .map(
                (p) => {
                  "id": p.id,
                  "title": p.title,
                  "quantity": p.quantity,
                  "price": p.price,
                },
              )
              .toList(),
        }),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: products,
          dateTime: DateTime.now(),
        ),
      );
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }
}
