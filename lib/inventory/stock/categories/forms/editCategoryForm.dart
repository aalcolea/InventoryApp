import 'dart:convert';
import 'dart:io';
import 'package:inventory_app/regEx.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_app/inventory/stock/categories/services/categoriesService.dart';

import '../../../themes/colors.dart';

class EditCategoryForm extends StatefulWidget {

  final int catID;
  final String catName;
  final String? catImage;
  final Function(bool) onLoad;

  const EditCategoryForm({Key? key, required this.catID, required this.catName, required this.onLoad, required this.catImage}) : super(key: key);

  @override
  _EditCategoryFormState createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends State<EditCategoryForm> {

  final CategoryService categoryService = CategoryService();

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

  @override
  void initState() {
    nameController.text = widget.catName;
    super.initState();
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
                        'Editar Categoría',
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
                        : widget.catImage == 'https://example.com/default.jpg' ? Column(
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
                    ) : SizedBox(
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
                        child: Image.network(
                          widget.catImage.toString(),
                          fit: BoxFit.contain,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                    onPressed: () async {
                      widget.onLoad(true);
                      await categoryService.updateCategoryInfo(context: context, idCategory: widget.catID, name: nameController.text, image: _selectedImage);
                    },
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
                        'Editar categoría',
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