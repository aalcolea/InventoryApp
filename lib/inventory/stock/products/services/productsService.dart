import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';

List<Map<String, dynamic>> products_global = [];
class ProductService {
  final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/productos'; //'http://192.168.101.140:8080/api/productos';//

  Future<void> fetchProducts(int categoryId) async {
    final String url = '$baseURL?category_id=$categoryId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      products_global.clear();

      products_global = data.map((product) {
        double price = 0.0;
        if (product['precio'] is String) {
          price = double.tryParse(product['precio']) ?? 0.0;
        } else if (product['precio'] is num) {
          price = (product['precio'] as num).toDouble();
        }

        return {
          'id' : product['id'],
          'product': product['nombre'],
          'catId': product['category_id'],
          'barCod': product['codigo_barras'],
          'descripcion': product['descripcion'],
          'price': price,
          'cant_cart': product['stock'],
          'product_id': product['id'],
        };
      }).toList();
    } else {
      throw Exception('Error al obtener los productos de la API');
    }
  }

  Future<bool> createProduct({required String nombre, required double precio, required String codigoBarras, String? descripcion, int? categoryId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    try {
      final Uri uri = Uri.parse(baseURL);
      final http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nombre'] = nombre;
      request.fields['precio'] = precio.toString();
      request.fields['codigo_barras'] = codigoBarras;
      if(descripcion != null){
        request.fields['descripcion'] = descripcion;
      }
      if(categoryId != null){
        request.fields['category_id'] = categoryId.toString();
      }
      final http.StreamedResponse response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode == 201) {
        print('Producto creado exitosamente');
        return true;
      } else {
        final responseData = jsonDecode(responseBody.body);
        throw Exception(responseData['message'] ?? 'Error al crear el producto');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error al crear el producto: $e');
    }
  }
  Future<bool> updateProductInfo({required int idProduct, required String name, required double price, required String barCod, String? desc, required catId, required int cant}) async{
    final url = Uri.parse(baseURL + '/$idProduct');
    print(barCod);
    try{
      final response = await http.put(
        url,
        headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        },
        body: jsonEncode({
          'nombre': name,
          'precio': price,
          'codigo_barras': barCod,
          'descripcion': desc,
          'category_id': catId,
          'cant': cant,
        }),
      );
      if(response.statusCode == 200){
        print('Producto Actualizado con exito');
        return true;
      }else{
        throw Exception('Error al crear el producto');
      }
    }catch(e){
      print('Error al editar el pructo');
      throw Exception('Error al modificar el producto: $e');
    }
  }

  Future<void> deleteProduct(int id) async{
    try {
      final response = await http.delete(
        Uri.parse('$baseURL/$id'),
      );
      if(response.statusCode == 204){
        print('Producto eliminado con exito');
      }else{
        print(response.statusCode);
        print('Response: ${response.body}');
      }
    }catch(e){
      print('Error: $e');
    }
  }
  Future<void> refreshProducts(int categryid) async {
    try {
      await fetchProducts(categryid);
    } catch (e) {
      print('Error en refresh productos $e');
    }
  }
}
