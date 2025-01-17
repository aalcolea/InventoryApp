import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import '../../../themes/colors.dart';

class CategoryService {
  final String baseURL = 'https://inventorioapp-ea98995372d9.herokuapp.com/api/categories';

  Future<File?> processImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        print("Error: No se pudo decodificar la imagen.");
        return null;
      }

      const maxSizeInBytes = 2048 * 512;
      if (imageFile.lengthSync() > maxSizeInBytes) {
        print("Reduciendo tamaño de la imagen...");
        final resizedImage = img.copyResize(decodedImage, width: 800);
        final compressedImage = img.encodeJpg(resizedImage, quality: 85);
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/processed_image.jpg');
        await tempFile.writeAsBytes(compressedImage);
        print("Imagen procesada guardada en: ${tempFile.path}");
        return tempFile;
      } else {
        print("La imagen es menor a 2 MB, no se requiere procesamiento.");
        return imageFile;
      }
    } catch (e) {
      print("Error al procesar la imagen: $e");
      return null;
    }
  }

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
      print('entra al try');
      final request = http.MultipartRequest('POST', url);
      request.headers['X-HTTP-Method-Override'] = 'PUT';
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = name;
      if (image != null && await image.exists()) {
        print("Procesando imagen...");
        final processedImage = await processImage(image);
        if (processedImage != null && await processedImage.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'foto',
            processedImage.path,
          ));
          print("Imagen procesada y agregada a la solicitud.");
        } else {
          print("Error: No se pudo procesar la imagen.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al procesar la imagen seleccionada.")),
          );
          return false;
        }
      }
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print("Cuerpo de la respuesta: ${responseBody.body}");

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
        print('else');
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