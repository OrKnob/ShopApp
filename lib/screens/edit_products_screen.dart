import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = './EditProductsScreen';

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _init = true;
  var _startValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  bool _isLoading = false;

  Product _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  FocusScopeNode currentFocus;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(listnerFunction);
  }

  @override
  void didChangeDependencies() {
    if (_init) {
      final _productId = ModalRoute.of(context).settings.arguments as String;
      if (_productId != null) {
        _editedProduct =
            Provider.of<ProductsProvider>(context).findById(_productId);
        _startValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
      }

      _imageUrlController.text = _editedProduct.imageUrl;
    }
    _init = false;
  }

  void listnerFunction() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          _imageUrlController.text.startsWith('https') &&
              _imageUrlController.text.startsWith('http') ||
          _imageUrlController.text.endsWith('.png') &&
              _imageUrlController.text.endsWith('.jpeg') &&
              _imageUrlController.text.endsWith('.jpg')) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(listnerFunction);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
  }

  void buildAgain() {
    setState(() {});
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .editProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  elevation: 2.0,
                  title: Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Text(
                    'Please try again later',
                    style: TextStyle(fontSize: 17),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'Okay',
                        style: TextStyle(fontSize: 17),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Widget ContainerOfTextFields(Widget child) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).accentColor, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: _isLoading ? 0.3 : 1.0,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Edit Your Products Here'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    _saveForm();
                  },
                )
              ],
            ),
            body: GestureDetector(
              onTap: () {
                currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      ContainerOfTextFields(
                        TextFormField(
                            initialValue: _startValues['title'],
                            style: TextStyle(fontSize: 22),
                            decoration: InputDecoration(
                                labelText: 'Name Of Product',
                                border: InputBorder.none,
                                labelStyle: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                                errorStyle: TextStyle(
                                  fontSize: 15,
                                )),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_priceFocusNode),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide a valid name for the Product';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: value,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: _editedProduct.imageUrl,
                                  isFavorite: _editedProduct.isFavorite);
                            }),
                      ),
                      ContainerOfTextFields(
                        TextFormField(
                          initialValue: _startValues['price'],
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 22),
                          decoration: InputDecoration(
                              labelText: 'Price',
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontSize: 17)),
                          textInputAction: TextInputAction.next,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Price should not be empty';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: double.parse(value),
                                imageUrl: _editedProduct.imageUrl,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                      ),
                      ContainerOfTextFields(
                        TextFormField(
                          initialValue: _startValues['description'],
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(fontSize: 22),
                          decoration: InputDecoration(
                              labelText: 'Description',
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontSize: 17)),
                          textInputAction: TextInputAction.newline,
                          focusNode: _descriptionFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Description should not be empty';
                            }
                            if (value.length < 10) {
                              return 'Description should have minimum 10 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: value,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).accentColor,
                                    width: 2),
                                borderRadius: BorderRadius.circular(20)),
                            width: 100,
                            height: 100,
                            child: _imageUrlController.text.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        'Enter a URL',
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: ContainerOfTextFields(
                              TextFormField(
                                focusNode: _imageUrlFocusNode,
                                controller: _imageUrlController,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(fontSize: 22),
                                decoration: InputDecoration(
                                    labelText: 'image URL',
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(fontSize: 17)),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'image URL cannot be empty';
                                  }
                                  if (!value.startsWith('https') &&
                                      !value.startsWith('http')) {
                                    return 'Please enter a valid image URL';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpeg') &&
                                      !value.endsWith('.jpg')) {
                                    return 'Please enter a valid image URL';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => buildAgain(),
                                onSaved: (value) {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      title: _editedProduct.title,
                                      description: _editedProduct.description,
                                      price: _editedProduct.price,
                                      imageUrl: value,
                                      isFavorite: _editedProduct.isFavorite);
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Text('')
      ],
    );
  }
}
