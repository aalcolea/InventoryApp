import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';

class CategoryService {
  final String baseURL = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories'; //'http://192.168.101.140:8080/api/categories';//

  Future<bool> updateCategoryInfo({required context, required int idCategory, required String name, required File? image}) async{
    final url = Uri.parse(baseURL + '/$idCategory');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa el nombre de la categoría")),
      );
      return false;
    }

    print(image);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    try{
      final request = http.MultipartRequest('POST', url);
      request.headers['X-HTTP-Method-Override'] = 'PUT';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = name;
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', image.path));
      }
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print(responseBody.body);

      if(response.statusCode == 200){
        Navigator.of(context).pop(true);
        print('Categoría actualizada con éxito');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.08,
                bottom: MediaQuery.of(context).size.width * 0.08,
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              content: Text('Categoría editada exitosamente',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: MediaQuery.of(context).size.width * 0.045),)),
        );
        return true;
      }else{
        String errorMessage = 'Error al crear la categoria';
        try {
          final responseData = jsonDecode(responseBody.body);
          errorMessage = responseData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error inesperado: ${responseBody.body}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.08,
                bottom: MediaQuery.of(context).size.width * 0.08,
                left: MediaQuery.of(context).size.width * 0.02,
              ),
              content: Text('Revise conexión a internet e intente de nuevo',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: MediaQuery.of(context).size.width * 0.045),)),
        );
        throw Exception('Error al crear la categoría ${response}');
      }
    }catch(e){
      print('Error al editar la categoría $e');
      throw Exception('Error al modificar la categoría: $e');
    }
  }
}