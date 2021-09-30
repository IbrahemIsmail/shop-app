import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/httpException.dart';
import '../widgets/appDrawer.dart';
import '../widgets/orderItem.dart';
import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _ordersFuture; //ensures this wont get rebuilt

  Future _obtainOrdersFuture() =>
      Provider.of<Orders>(context, listen: false).fetchAndSetOrders();

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (dataSnapshot.error != null)
            throw HttpException('something went wrong!');
          else
            return Consumer<Orders>(
              builder: (ctx, ordersData, child) => ListView.builder(
                itemCount: ordersData.orders.length,
                itemBuilder: (ctx, i) => OrderItem(ordersData.orders[i]),
              ),
            );
        },
      ),
    );
  }
}
