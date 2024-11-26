import 'dart:convert';
import 'dart:io';
import 'package:beaute_app/regEx.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../themes/colors.dart';

class CategoryForm extends StatefulWidget {

  const CategoryForm({Key? key}) : super(key: key);

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  TextEditingController nameController = TextEditingController();
  File? _selectedImage;
  final picker = ImagePicker();
  bool isLoading = false;
  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso denegado para acceder a las imágenes')),
      );
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> createCategory() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor ingresa el nombre de la categoría")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    const baseUrl = 'https://beauteapp-dd0175830cc2.herokuapp.com/api/categories';
    String? token = prefs.getString('jwt_token');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nombre'] = nameController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _selectedImage!.path));
      }

      final response = await request.send();

      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.08,
                  bottom: MediaQuery.of(context).size.width * 0.08,
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                content: Text('Categoria creada exitosamente',
                  style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: MediaQuery.of(context).size.width * 0.045),)),
          );
          Navigator.of(context).pop(true);
        }

      }else{
        String errorMessage = 'Error al crear la categoria';
        try {
          final responseData = jsonDecode(responseBody.body);
          errorMessage = responseData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Error inesperado: ${responseBody.body}';
        }
        if(mounted){
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
        }
      }
      SnackBar(content: Text("asdasd"));
    } catch (e) {
      SnackBar(content: Text("Fallo"));
      print("Errdasdor: $e");


      print('errr inesperado ${e}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
              bottom: MediaQuery.of(context).size.width * 0.05,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.whiteColor,
            ),
            child: Column(

              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                      child: Text(
                        'Crear Categoría',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: MediaQuery.of(context).size.width * 0.075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.width * 0.105,
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.035,
                    bottom: MediaQuery.of(context).size.width * 0.01
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Nombre de la categoría:',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.105,
                  child: TextFormField(
                    inputFormatters: [RegEx(type: InputFormatterType.alphanumeric)],
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.03),
                      hintText: 'Nombre de la categoría...',
                      hintStyle: TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.10,
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.035,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10)
                        ),
                      ),
                      child: Text(
                        'Cargar imagen',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _selectedImage != null ?
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: _requestPermission,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteColor,
                            side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)
                                )
                            )
                        ),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      ),
                    )
                    : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.10,
                          child: ElevatedButton(
                            onPressed: _requestPermission,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.whiteColor,
                                side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)
                                    )
                                )
                            ),
                            child: Text(
                              'Seleccionar Imagen',
                              style: TextStyle(
                                color: AppColors.primaryColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                          child: const Text(
                            '*No se ha seleccionado una imagen',
                            style: TextStyle(
                              color: AppColors.primaryColor
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: createCategory,
                    style: ElevatedButton.styleFrom(
                      splashFactory: InkRipple.splashFactory,
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: MediaQuery.of(context).size.width * 0.0112),
                      surfaceTintColor: AppColors.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.5,
                        MediaQuery.of(context).size.height * 0.07,
                      ),
                      backgroundColor: AppColors.whiteColor,
                    ),
                    child: Text(
                        'Crear categoría',
                        style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.width * 0.055,
                          color: AppColors.primaryColor,
                        )
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}