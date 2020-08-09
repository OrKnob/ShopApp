import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/productDetailScreen';

  @override
  Widget build(BuildContext context) {
    final _productId = ModalRoute.of(context).settings.arguments as String;
    final _productData = Provider.of<ProductsProvider>(context,
        listen:
            false); //adding listen argument to false here will not allow the widget to rebuild for every change in global data.
    final _product = _productData.findById(_productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(_product.imageUrl),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$' + _product.price.toString(),
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                width: double.infinity,
                child: Text(
                  _product.description.toString(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 17),
                ))
          ],
        ),
      ),
    );
  }
}
