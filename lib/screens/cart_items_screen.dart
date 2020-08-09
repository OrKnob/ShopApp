import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../providers/cart.dart';
import '../widgets/cart_item.dart' as CI;
import '../providers/orders.dart';

class CartItemsScreen extends StatelessWidget {
  static const routeName = '/CartItems';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _cartData = Provider.of<Cart>(context);
    final _cartItemsMap = _cartData.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carts Screen'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 22),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$ ' + _cartData.totalAmount.toStringAsFixed(2),
                      style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.title.color,
                          fontSize: 19),
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                  OrderButton(cart: _cartData),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CI.CartItem(
                  _cartItemsMap.keys.toList()[i],
                  _cartItemsMap.values.toList()[i].id,
                  _cartItemsMap.values.toList()[i].price,
                  _cartItemsMap.values.toList()[i].quantity,
                  _cartItemsMap.values.toList()[i].title),
              itemCount: _cartData.individualQuantity,
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? CircularProgressIndicator()
          : Text(
              'ORDER NOW',
              style: TextStyle(fontSize: 15),
            ),
      onPressed: (widget.cart.totalAmount <= 0)
          ? null
          : () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                print('start of execution');
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                print('end of execution');
                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
              } catch (error) {}
            },
    );
  }
}
