import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../widgets/order_item.dart' as OI;
import '../widgets/main_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = './ordersScreen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;

  @override
  void didChangeDependencies() async {
    if (_isLoading) {
      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: MainDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ordersData.orders.length == 0
              ? Center(
                  child: Text(
                    'You have not placed any orders yet!',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (ctx, i) => OI.OrderItem(ordersData.orders[i]),
                  itemCount: ordersData.orders.length,
                ),
    );
  }
}
