import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/orders_screen.dart';
import './providers/products_provider.dart';
import './screens/product_detail_screen.dart';
import './screens/product_overview_screen.dart';
import 'providers/cart.dart';
import './screens/cart_items_screen.dart';
import 'providers/orders.dart';
import './screens/user_products_screen.dart';
import './screens/edit_products_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
            //using ProxyProvider tells us that this provider depends on the previous provider for some value
            update: (ctx, auth, previousProductsProvider) => ProductsProvider(
                auth.token,
                previousProductsProvider == null
                    ? []
                    : previousProductsProvider.products,
                auth.userId), // when Auth changes it will tell the provider to rebuild.
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                previousOrders == null ? [] : previousOrders.orders,
                auth.userId),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
        ],
        child: Consumer<Auth>(
            builder: (ctx, authData, _) => MaterialApp(
                  title: 'Flutter Demo',
                  theme: ThemeData(
                      primarySwatch: Colors.indigo,
                      primaryColor: Colors.black,
                      accentColor: Colors.deepOrange,
                      fontFamily: 'Lato'),
                  home: authData.doLogout
                      ? AuthScreen()
                      : authData.isAuth
                          ? ProductOverviewScreen()
                          : authData.theToken == null
                              ? AuthScreen()
                              : FutureBuilder(
                                  future: authData.tryAutoLogin(),
                                  builder: (ctx, dataSnapshot) =>
                                      dataSnapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? SplashScreen()
                                          : AuthScreen(),
                                ),
                  routes: {
                    ProductDetailScreen.routeName: (ctx) =>
                        ProductDetailScreen(),
                    CartItemsScreen.routeName: (ctx) => CartItemsScreen(),
                    OrdersScreen.routeName: (ctx) => OrdersScreen(),
                    ProductOverviewScreen.routeName: (ctx) =>
                        ProductOverviewScreen(),
                    UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                    EditProductsScreen.routeName: (ctx) => EditProductsScreen(),
                  },
                )));
  }
}

//Important Readme
//for listening data for lists or grids we use ChangeNotifierProvider.value approach instead of ChangeNotifierProvider(builder) approach
//if we dont want the whole widget tree to listen to the changed data then we use consumer on top of the widget that only listens.
//
