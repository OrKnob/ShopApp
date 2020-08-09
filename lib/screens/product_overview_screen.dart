import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../widgets/main_drawer.dart';
import '../widgets/products_grid.dart';

import '../providers/cart.dart';
import '../widgets/badge.dart';
import './cart_items_screen.dart';
import '../providers/products_provider.dart';
import '../providers/auth.dart';

enum FilterOptions { Favorites, All, LogOut }

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = './productsScreen';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isFavorite = false;
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = true;
      try {
        Provider.of<ProductsProvider>(context).fetchProducts(false).then((_) {
          setState(() {
            _isLoading = false;
            _isInit = false;
          });
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
          _isInit = false;
        });
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.countCartItems.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartItemsScreen.routeName);
              },
            ),
          ),
          PopupMenuButton(
              onSelected: (FilterOptions value) {
                if (value == FilterOptions.LogOut) {
                  Provider.of<Auth>(context, listen: false).LogOut();
                }
                setState(() {
                  if (value == FilterOptions.Favorites) {
                    _isFavorite = true;
                  } else {
                    _isFavorite = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Favorites'),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('All Products'),
                      value: FilterOptions.All,
                    ),
                    PopupMenuItem(
                      child: Text('LogOut'),
                      value: FilterOptions.LogOut,
                    )
                  ])
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_isFavorite),
    );
  }
}
