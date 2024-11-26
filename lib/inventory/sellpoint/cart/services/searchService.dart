import 'dart:convert';

import 'package:http/http.dart' as http;

class SearchService {
  Future<Map<String, dynamic>> searchProductsAndCategories(String searchTerm) async {
    final url = Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/search?q=$searchTerm');
    final response = await http.get(url);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return {
        'categories': data['categories'],
        'productos': data['productos'],
      };
    }else{
      throw Exception('Error en la búsqueda');
    }
  }
  Future<Map<String,  dynamic>> searchByBCode(String? barCode) async {
    final url = Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/searchByBCode?barCode=$barCode');
    final response = await http.get(url);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return {
        'productos': data['data'],
      };
    }else{
      throw Exception('Error en la búsqueda');
    }
  }
}
