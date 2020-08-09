import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_products_screen.dart';
import '../screens/user_products_screen.dart';

class UserProductItem extends StatelessWidget {
  final String _title;
  final String _imageUrl;
  final String _id;

  UserProductItem(this._title, this._imageUrl, this._id);

  Future<void> _deleteProduct(
      BuildContext context, String id, ScaffoldState scaffold) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('Are You Sure?'),
                content: Text(
                    'Do you want to delete the product from the database?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.pop(ctx, false);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () async {
                      Navigator.pop(ctx, true);
                      try {
                        await Provider.of<ProductsProvider>(context,
                                listen: false)
                            .deleteProduct(id);
                      } catch (error) {
                        scaffold.showSnackBar(SnackBar(
                          content: Text(
                            'Product deletion failed',
                            textAlign: TextAlign.center,
                          ),
                        ));
                      }
                    },
                  )
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(_title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(_imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pushNamed(context, EditProductsScreen.routeName,
                    arguments: _id);
              },
            ),
            IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  _deleteProduct(context, _id, scaffold);
                })
          ],
        ),
      ),
    );
  }
}
