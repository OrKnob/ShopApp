import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products_provider.dart';
import '../screens/edit_products_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = './userProductsScreen';
  bool isDeleting = false;

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchProducts(true);
  }

  void deleteTheProduct() {
    isDeleting = true;
  }

  @override
  Widget build(BuildContext context) {
//    final _productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.pushNamed(context, EditProductsScreen.routeName);
            },
          )
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(5),
                        child: ListView.builder(
                          itemBuilder: (_, i) => UserProductItem(
                              productsData.products[i].title,
                              productsData.products[i].imageUrl,
                              productsData.products[i].id),
                          itemCount: productsData.products.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
