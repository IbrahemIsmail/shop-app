import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splashScreen.dart';
import './screens/authScreen.dart';
import './screens/editProductScreen.dart';
import './screens/userProductsScreen.dart';
import './screens/cartScreen.dart';
import './screens/productDetailScreen.dart';
import './screens/productsOverviewScreen.dart';
import './screens/ordersScreen.dart';

import './providers/auth.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './providers/orders.dart';

import './helpers/CustomRoute.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products([], '', ''),
          update: (ctx, auth, oldProducts) => Products(
            oldProducts == null ? [] : oldProducts.items,
            auth.token as String,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, oldOrders) => Orders(
            auth.token as String,
            auth.userId,
            oldOrders == null ? [] : oldOrders.orders,
          ),
          create: (ctx) => Orders(null, null, []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, staticThingy) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
