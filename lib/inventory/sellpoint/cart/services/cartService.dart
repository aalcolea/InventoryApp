import 'dart:convert';
import 'package:beaute_app/inventory/stock/products/services/productsService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../admin.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];
  List<Map<String, dynamic>> get cart => _cart;
  double total_price = 0;

  void addProductToCart(int product_id, {bool isFromBarCode = false}) {
    final productSource = isFromBarCode ? productsGlobalTemp : products_global;
    print(productSource);
    final productInCart = _cart.firstWhere(
          (prod) => prod['product_id'] == product_id,
      orElse: () => <String, dynamic>{},
    );
    if(productInCart.isNotEmpty){
      final stockDisponible = productInCart['stock'];
      if (productInCart['cant_cart'] < stockDisponible) {
        productInCart['cant_cart'] += 1;
        print('Cantidad incrementada para el producto con id: $product_id');
      } else {
        print('No puedes agregar más de lo disponible en stock');
      }
    }else{
      final product = productSource.firstWhere(
            (prod) => prod['product_id'] == product_id || prod['id'] == product_id,
        orElse: () => <String, dynamic>{},
      );
      if(product.isNotEmpty){
        int stockDisponible = 0;
        if (product.containsKey('stock') && product['stock'] is Map) {
          stockDisponible = product['stock']['cantidad'] ?? 0;
        }else if(product.containsKey('cant_cart') && product['cant_cart'] is Map) {
          stockDisponible = product['cant_cart']['cantidad'] ?? 0;
        }
        _cart.add({
          'product': product['product'] ?? product['nombre'],
          'price': product['price'] ?? double.parse(product['precio']),
          'cant_cart': 1.0,
          'product_id': product['id'] ?? product['product_id'],
          'stock': stockDisponible,
        });
        print('Producto agregado al carrito: ${product['product'] ?? product['nombre']}');
      }else{
        print('Producto no encontrado en la fuente de productos');
      }
    }
    notifyListeners();
    print('Estado actual del carrito: $_cart');
  }
  void addProductToCartByBarCode(Map<String, dynamic> product) {
    final int productIndex = _cart.indexWhere((prod) => prod['product_id'] == product['id']);
    if(productIndex != -1){
      final productInCart = _cart[productIndex];
      final stockDisponible = productInCart['stock'];
      print('hola $stockDisponible');
      print('adios ${productInCart['cant_cart']}');

      if(productInCart['cant_cart'] < stockDisponible){
        _cart[productIndex]['cant_cart'] += 1;
        print('Cantidad incrementada para el producto con id: ${product['id']}');
      }else{
        print('No puedes agregar más de lo disponible en stock');
      }
    }else{
      _cart.add({
        'product': product['nombre'],
        'price': double.parse(product['precio']),
        'cant_cart': 1.0,
        'product_id': product['id'],
        'stock': product['stock']['cantidad'],
      });
      print('Producto agregado al carrito: ${product['nombre']}');
    }
    notifyListeners();
    print('carrito test: $_cart');
  }
  void decrementProductInCart(int productId){
    for (var item in _cart) {
      if (item['product_id'] == productId) {
        if (item['cant_cart'] > 1) {
          item['cant_cart'] -= 1;
        } else {
          _cart.remove(item);
        }
        break;
      }
    }
    notifyListeners();
  }
  int getProductCount(int productId){
    final productInCart = _cart.firstWhere(
          (item) => item['product_id'] == productId,
      orElse: () => <String, dynamic>{},
    );
    return productInCart.isNotEmpty && productInCart['cant_cart'] is num ? (productInCart['cant_cart'] as num).toInt() : 0;
  }
  Future<bool> sendCart() async {
    List<Map<String, dynamic>> transformedCart = _cart.map((item){
      return {
        'producto_id' : item['product_id'],
        'cant_cart': item['cant_cart'].toInt(),
      };
    }).toList();
    final body = jsonEncode({
      'carrito': transformedCart,
    });
    print('Carrito mandado:$transformedCart');
    final response = await http.post(
      Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/carrito'),
      //Uri.parse('http://192.168.101.140:8080/api/carrito'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 201) {
      print('Carrito enviado correctamente y actualizado');
      _cart.clear();
      return true;
    } else {
      print('Error al enviar carrito: ${response.body}');
      return false;
    }
  }
  void refreshCart() {
    _cart.clear();
    notifyListeners();
  }

}