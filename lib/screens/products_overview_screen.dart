import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/main_drawer.dart';
import '../screens/cart_screen.dart';
import '../providers/cart.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    // final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              switch (selectedValue) {
                case FilterOptions.Favorites:
                  setState(() {
                    _showOnlyFavorites = true;
                  });
                  // productsContainer.setShowFavoritesOnly(true);
                  break;
                case FilterOptions.All:
                  setState(() {
                    _showOnlyFavorites = false;
                  });
                  // productsContainer.setShowFavoritesOnly(false);
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
            builder: (_, value, child) => Badge(
              child: child,
              value: value.itemCount.toString(),
            ),
          )
        ],
        title: Text('MyShop'),
      ),
      drawer: MainDrawer(),
      body: ProductsGrid(_showOnlyFavorites),
    );
  }
}
