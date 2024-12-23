import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  //final String baseURL = 'http://192.168.101.140:8080/api/stock';
  final String baseURL = 'https://inventorioapp-ea98995372d9.herokuapp.com/api/stock';

  Future<bool> updateProductStock ({required int idProduct, required int stockValue, required int controllerValue}) async {
    final url = Uri.parse(baseURL);
    final int newStockValue = controllerValue - stockValue;
    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'producto_id': idProduct,
          'cantidad': newStockValue,
          'estado': 'disponible'
        }),
      );
      if(response.statusCode == 201){
        print('Producto Actualizado con exito');
        return true;
      }else{
        throw Exception('Error al modificar el producto ${response.body}');
      }
    }catch(e){
      print('Error al editar el pructo');
      throw Exception('$e');
    }
  }
}