import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../themes/colors.dart';
import '../../utils/listenerCatBox.dart';

class CategoryBox extends StatefulWidget {
  final int formType;
  final Function(int)? onSelectedCat;
  final int? selectedCatId;
  final ListenerCatBox? listernerCatBox;
  const CategoryBox({super.key, required this.formType, required this.onSelectedCat, this.selectedCatId, this.listernerCatBox});

  @override
  State<CategoryBox> createState() => _CategoryBoxState();
}

class _CategoryBoxState extends State<CategoryBox> {
  Map<String, dynamic>? categorySel;
  List<Map<String, dynamic>> items = [];
  bool lock = false;

  @override
  void initState() {
    super.initState();
    widget.formType == 2 ? lock = true : lock = false;//formtype 2 es para modificar
    fetchItems();
    widget.listernerCatBox?.registrarObservador((newValue){
      lock = newValue;
      print('newVak $newValue');
    });
  }
  ///RECORDAR MANDAR A SERVCIO
  Future<void> fetchItems({int limit = 100, int offset = 0}) async {
    const String baseURL = 'https://inventorioapp-ea98995372d9.herokuapp.com/api/categories';
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        items = data.map((item) {
          return {
            'id': item['id'],
            'category': item['nombre'],
            'image': item['foto'],
          };
        }).where((item) => item['category'] != null).toList();

        if (widget.selectedCatId != null) {
          categorySel = items.firstWhere(
                (item) => item['id'] == widget.selectedCatId,
            orElse: () => items.isNotEmpty ? items[0] : {},
          );
        }
      });
    } else {
      throw Exception('Error al obtener datos de la API');
    }
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Map<String, dynamic>>(
      isExpanded: true,
      hint: Text(
        'Categoria del producto',
        style: TextStyle(
          color: lock == false ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.5),
        ),
      ),
      value: categorySel,
      items: items.map((categoryItem) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: categoryItem,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              categoryItem['category'] ?? 'Categoria Null',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }).toList(),
      onChanged: !lock ? (selectedCategory) {
        setState(() {
          categorySel = selectedCategory;
          if (widget.onSelectedCat != null && selectedCategory != null) {
            final int catID = selectedCategory['id'];
            widget.onSelectedCat!(catID);
          }
        });
      } : null,
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una opción';
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.02),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.width * 0.5,
        ),
        focusedBorder: widget.formType == 1 ? const OutlineInputBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 0.7,
          ),
        ) : const OutlineInputBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 0.7,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: lock == false  ? AppColors.blackColor.withOpacity(0.5) : AppColors.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: lock == false  ? AppColors.blackColor.withOpacity(0.5) : AppColors.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
      ),
      style: const TextStyle(fontSize: 18, color: Color(0xFF48454C)),
      icon: const Icon(Icons.arrow_drop_down),
      selectedItemBuilder: (BuildContext context) {
        return items.map((categoryItem) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                categoryItem['category'] ?? 'Categoria Null',
                style: TextStyle(color: lock == false ? AppColors.primaryColor: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          );
        }).toList();

      },
    );
  }
}
