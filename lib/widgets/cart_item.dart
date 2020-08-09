import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String _cartItemId;
  final String _id;
  final double _price;
  final int _quantity;
  final String _title;

  CartItem(
      this._cartItemId, this._id, this._price, this._quantity, this._title);

  @override
  Widget build(BuildContext context) {
    final _cartData = Provider.of<Cart>(context, listen: false);

    return Dismissible(
      key: ValueKey(_id),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        padding: EdgeInsets.only(right: 10),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are You Sure?'),
                  content:
                      Text('Do you want to remove the item from the cart?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.pop(ctx, false);
                      },
                    ),
                    FlatButton(
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.pop(ctx, true);
                      },
                    )
                  ],
                ));
      },
      onDismissed: (direction) {
        _cartData.removeItem(_cartItemId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 27,
              backgroundColor: Theme.of(context).accentColor,
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '\$ ' + _price.toString(),
                    style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                        fontSize: 20),
                  ),
                ),
              ),
            ),
            title: Text(_title),
            subtitle: Text('\$' + (_price * _quantity).toStringAsFixed(2)),
            trailing: Text(_quantity.toString() + 'x'),
          ),
        ),
      ),
    );
  }
}
