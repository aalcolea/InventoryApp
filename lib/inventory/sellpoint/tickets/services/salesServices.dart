import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../globalVar.dart';

List<Map<String, dynamic>> sales = [];
List<Map<String, dynamic>> salesByProduct = [];

class SalesServices{

  final String baseURL = '${SessionManager.instance.baseURL}/ventas/carrito';//?fecha_inicio=2024-10-15&fecha_fin=2024-10-15'

  Future<List<Map<String,dynamic>>> fetchSales(String? fechaInicio, String? fechaFin) async{
    String fechaSelected = '';
    if (fechaInicio != null) {
      fechaSelected = '?fecha_inicio=${fechaInicio}&fecha_fin=${fechaFin}';
    }
    final response =  await http.get(Uri.parse(baseURL+fechaSelected));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      var formatter = new DateFormat('dd-MM-yyyy');
      return sales = data.map((sales){
        DateTime fecha = DateTime.parse(sales['created_at']);
        return {
          'id' : sales['id'],
          'total' : sales['total'],
          'fecha' : formatter.format(fecha),
          'cantidad' : sales['cantidad'],
          'detalles' : sales['detalles'],

        };
      }).toList();
    }else{
      throw Exception('Error al obtener las ventas de la API');
    }
  }

  Future<List<Map<String,dynamic>>> getSalesByProduct(String? fechaInicio, String? fechaFin) async{
    String url = '$baseURL?fecha_inicio=${fechaInicio ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}&fecha_fin=${fechaFin ?? DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('jajaja $data');
      Map<String, Map<String, dynamic>> productosMap = {};
      var formatter = new DateFormat('dd-MM-yyyy');
      data.expand((venta) => venta['detalles']).forEach((detalle) {
        final producto = detalle['producto'];
        final idProd = producto['id'].toString();
        final nombreProducto = producto['nombre'];
        final fecha = DateTime.parse(producto['created_at']).toString();
        DateTime fecha_venta = DateTime.parse(data[0]['created_at']);
        final int cantidad = int.tryParse(detalle['cantidad'].toString()) ?? 0;
        final double precio = double.tryParse(detalle['precio'].toString()) ?? 0.0;
        final category_id = producto['category_id'];
        if (productosMap.containsKey(idProd)) {
          print('if');
          productosMap[idProd]!['cantidad'] += cantidad;
          productosMap[idProd]!['total'] += cantidad * precio;
        }else{
          print('else');
          productosMap[idProd] = {
            'nombre': nombreProducto,
            'cantidad': cantidad,
            'precio': precio,
            'total': cantidad * precio,
            'fecha': fecha,
            'fecha_venta': formatter.format(fecha_venta),
            'category_id': category_id
          };
        }
      });
      return productosMap.entries.map((entry){
        return {
          'id': entry.key,
          'nombre': entry.value['nombre'],
          'cantidad': entry.value['cantidad'],
          'precio': entry.value['precio'],
          'total': entry.value['total'],
          'fecha': entry.value['fecha'],
          'fecha_venta': entry.value['fecha_venta'],
          'category_id': entry.value['category_id']
        };
      }).toList();
    } else{
      throw Exception('Error al obtener los productos vendidos');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories({int limit = 6, int offset = 0}) async{
    final response = await http.get(Uri.parse('https://inventorioapp-ea98995372d9.herokuapp.com/api/categories?limit=$limit&offset=$offset'));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item){
        return {
          'id' : item['id'].toString(),
          'category': item['nombre'],
          'image': item['foto'],
        };
      }).toList();
    }else{
      throw Exception('Error al obtener datos de la API');
    }
  }
}