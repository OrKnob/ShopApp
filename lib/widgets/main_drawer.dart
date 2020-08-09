import 'package:flutter/material.dart';
import 'package:shopapp/screens/product_overview_screen.dart';
import 'package:shopapp/screens/user_products_screen.dart';

import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(IconData icon, String title, Function function) {
    return ListTile(
      onTap: function,
      leading: Icon(
        icon,
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Text(
              'Hey There',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          buildListTile(Icons.shop, 'Overall Products', () {
            Navigator.of(context)
                .pushReplacementNamed(ProductOverviewScreen.routeName);
          }),
          Divider(
            thickness: 3,
          ),
          buildListTile(Icons.payment, 'Your Orders', () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          }),
          Divider(
            thickness: 3,
          ),
          buildListTile(Icons.account_balance_wallet, 'Manage Products', () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName);
          }),
        ],
      ),
    );
  }
}
