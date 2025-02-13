import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/helpers/utils/showToast.dart';
import 'package:inventory_app/helpers/utils/toastWidget.dart';
import 'package:inventory_app/inventory/stock/addProd/cards/productToAdd.dart';
import 'package:inventory_app/regEx.dart';
import '../../../deviceManager.dart';
import '../../../sellpoint/cart/services/searchService.dart';
import '../../../themes/colors.dart';
import '../cards/addProdDialog.dart';

class RecieveProduct extends StatefulWidget {
  const RecieveProduct({super.key});

  @override
  State<RecieveProduct> createState() => _RecieveProdState();
}

class _RecieveProdState extends State<RecieveProduct> {

  late DeviceInfo deviceInfo;
  var orientation = Orientation.portrait;
  bool isTablet = false;
  double? screenWidth;
  double? screenHeight;
  final SearchService searchService = SearchService();
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  List<Map<String, dynamic>> productos = []; // Lista de productos obtenidos
  List<Map<String, dynamic>> productsToAdd = []; // Lista de productos obtenidos
  List<GlobalKey> productKeys = [];
  List<TextEditingController> stockControllersList = [];
  bool isLoading = false;
  final GlobalKey _txtSearch = GlobalKey();
  double total = 0;
  bool showBlurr = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deviceInfo = DeviceInfo();
    productsToAdd = [];
    productos = [];
    WidgetsBinding.instance.addPostFrameCallback((_){
      txtWidth = _txtSearch.currentContext?.size!.width;
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // Limpiar el controller
    super.dispose();
  }

  double? txtWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
  }

  void didChangeMetrics() {
    if (mounted) {
      setState(() {
        deviceInfo = DeviceInfo(); // Recalcular cuando cambian las métricas
      });
    }
  }

  Future<List<Map<String, dynamic>>> searchProductsAndCategories(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() => productos = []);
      return [];
    }

    setState(() => isLoading = true);
    try {
      final data = await searchService.searchProductsAndCategories(searchTerm);
      if (searchController.text == searchTerm) {
        setState(() {
          productos = List<Map<String, dynamic>>.from(data['productos']);
        });
      }
      return productos;
    } catch (e) {
      print('Error: $e');
      return [];
    } finally {
      if (searchController.text == searchTerm) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              leadingWidth: MediaQuery.of(context).size.width,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      CupertinoIcons.back,
                      size: !isTablet ? MediaQuery.of(context).size.width * 0.08 : orientation == Orientation.portrait ?
                      MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.08,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text('Recibir producto', style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: !deviceInfo.isTablet ? screenWidth! < 370.00
                        ? MediaQuery.of(context).size.width * 0.078
                        : MediaQuery.of(context).size.width * 0.082 : orientation == Orientation.portrait ?
                    MediaQuery.of(context).size.width * 0.073 : MediaQuery.of(context).size.height * 0.078,
                    fontWeight: FontWeight.w500,
                  ),),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            body: Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.02,
                                left: MediaQuery.of(context).size.width * 0.03,
                                bottom: MediaQuery.of(context).size.width * 0.025,
                                top: MediaQuery.of(context).size.width * 0.005
                            ),
                            child: Container(
                              color: Colors.transparent,
                              child: Autocomplete<Map<String, dynamic>>(
                                optionsBuilder: (TextEditingValue textEditingValue) async {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Map<String, dynamic>>.empty();
                                  }
                                  return await searchProductsAndCategories(textEditingValue.text);
                                },
                                displayStringForOption: (option) => option['nombre'] ?? '',
                                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                  searchController = controller;
                                  return TextFormField(
                                    inputFormatters: [
                                      RegEx(type: InputFormatterType.namesymbols)
                                    ],
                                    key: _txtSearch,
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar producto...',
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                      suffixIcon: controller.text.isNotEmpty
                                          ? IconButton(
                                        onPressed: () {
                                          controller.clear();
                                          setState(() => productos = []);
                                        },
                                        icon: const Icon(CupertinoIcons.clear, color: Colors.grey),
                                      ) : null,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                    ),
                                    onChanged: (value) {
                                      searchProductsAndCategories(value);
                                    },
                                  );
                                },
                                onSelected: (Map<String, dynamic> selectedProduct) {
                                  setState(() {
                                    productsToAdd.add({
                                      'nombre': selectedProduct['nombre'],
                                      'precioRet': selectedProduct['precioRet'],
                                      'controller' : TextEditingController(text: '1'),
                                      'cantToAdd' : 1,
                                    });
                                    searchController.clear();
                                    productos = [];
                                    total = productsToAdd.fold(0.0, (sum, item) => sum + double.parse(item['precioRet'].toString()) * item['cantToAdd']);
                                  });
                                },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.blackColor.withOpacity(0.2),
                                          ),
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          color: AppColors.whiteColor.withOpacity(0.9),
                                        ),
                                        width: txtWidth,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final Map<String, dynamic> option = options.elementAt(index);
                                            return ListTile(
                                              title: Text(option['nombre']),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                      child: Container(
                        margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: productsToAdd.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CardProductToAdd(
                                  productsToAdd: productsToAdd,
                                  index: index,
                                  onIndexToDelete: (indexToDelete){
                                    setState(() => productsToAdd.removeAt(indexToDelete));
                                    total = productsToAdd.fold(0.0, (sum, item) => sum + double.parse(item['precioRet'].toString()) * item['cantToAdd']);
                                  },
                                  onCalculateTotal: (indexToModify, cantToAdd) {
                                    setState(()=> productsToAdd[indexToModify]['cantToAdd'] = cantToAdd);
                                    total = productsToAdd.fold(0.0, (sum, item) => sum + double.parse(item['precioRet'].toString()) * item['cantToAdd']);
                                  },
                                ),
                                Divider(
                                  thickness: 2.0,
                                  color: AppColors.primaryColor.withOpacity(0.45),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                  ),
                  Visibility(
                      visible: productsToAdd.isNotEmpty ? true : false,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Total:  \$$total', style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                      color: AppColors.primaryColor
                                  ),),
                                  Text('MXN', style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    color: AppColors.primaryColor.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ))])])),
                  Visibility(
                      visible: productsToAdd.isNotEmpty ? true : false,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width * 0.032,
                              horizontal: MediaQuery.of(context).size.width * 0.032,
                            ),
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: (){
                            setState(() async {
                              showBlurr = true;
                              final confirmData = await showConfirmAddDialog(context);
                              if(confirmData?['confirm'] == true){
                                setState(() {
                                  showBlurr = false;
                                  showOverlay(context, const CustomToast(message: 'Movimiento efectuado de manera exitosa'));
                                });
                              }else {
                                setState(()=> showBlurr =false);
                              }
                            });
                          }, child: Text('Recibir Producto', style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),))),
                ])),
        Visibility(
          visible: showBlurr ? true : false,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showBlurr = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.blackColor.withOpacity(0.3),
                ),
              )
          ),)
      ],
    );
  }
}
