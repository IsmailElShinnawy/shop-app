import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/product_detail_sceen.dart';

import './screens/products_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyShop',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.deepOrange,
        fontFamily: 'Lato',
      ),
      initialRoute: ProductsOverviewScreen.routeName,
      routes: {
        ProductsOverviewScreen.routeName: (_) => ProductsOverviewScreen(),
        ProductDetailSceen.routeName: (_) => ProductDetailSceen(),
      },
    );
  }
}
