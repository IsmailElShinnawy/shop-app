import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductSceen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductSceenState createState() => _EditProductSceenState();
}

class _EditProductSceenState extends State<EditProductSceen> {
  // final _priceFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.jpg'))) return;
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'An error occured',
            ),
            content: Text(
              'Something went wrong.',
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
      // Provider.of<Products>(context, listen: false)
      //     .addProduct(_editedProduct)
      //     .catchError((err) {
      //   return showDialog<Null>(
      //     context: context,
      //     builder: (ctx) => AlertDialog(
      //       title: Text(
      //         'An error occured',
      //       ),
      //       content: Text(
      //         'Something went wrong.',
      //       ),
      //       actions: [
      //         FlatButton(
      //           onPressed: () {
      //             Navigator.of(ctx).pop();
      //           },
      //           child: Text('Okay'),
      //         )
      //       ],
      //     ),
      //   );
      // }).then((_) {
      // setState(() {
      //   _isLoading = false;
      // });
      // Navigator.of(context).pop();
      // });
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toStringAsFixed(2),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _priceFocusNode.dispose();
    _imageUrlController.dispose();

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      // onFieldSubmitted: (_) {
                      //   FocusScope.of(context).requestFocus(_priceFocusNode);
                      // },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        return value.isEmpty ? 'Please provide a value' : null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a price';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid price';
                        if (double.parse(value) <= 0)
                          return 'Please enter a price greater than zero';
                        return null;
                      },
                      // focusNode: _priceFocusNode,
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          description: value,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a description';
                        if (value.length < 10)
                          return 'Your description must be at least 10 characters';
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                imageUrl: value,
                                description: _editedProduct.description,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL.';
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.jpg'))
                                return 'Please enter a valid image URL';
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
