import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../deviceThresholds.dart';
import '../../../../regEx.dart';
import '../../../deviceManager.dart';
import '../../../themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../kboardVisibilityManager.dart';
import '../../categories/forms/categoryBox.dart';
import '../../utils/listenerCatBox.dart';
import '../services/productsService.dart';
import '../styles/productFormStyles.dart';
import '../utils/PopUpTabs/deleteProductDialog.dart';

class ProductDetails extends StatefulWidget {
  final int idProduct;
  final String nameProd;
  final String descriptionProd;
  final String barCode;
  final int stock;
  final double precio;
  final double precioRetail;
  final int catId;
  final Future<void> Function() onProductModified;
  final Future<void> Function() onProductDeleted;
  final void Function(
      bool
      ) onShowBlur;

  const ProductDetails({super.key, required this.idProduct, required this.nameProd, required this.descriptionProd, required this.barCode, required this.stock, required this.precio, required this.catId, required this.onProductModified, required this.onShowBlur, required this.precioRetail, required this.onProductDeleted});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> with WidgetsBindingObserver{

  //
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  TextEditingController precioController = TextEditingController();
  FocusNode precioFocus = FocusNode();
  TextEditingController precioRetailController = TextEditingController();
  FocusNode precioRetailFocus = FocusNode();
  TextEditingController stockController = TextEditingController();
  FocusNode stockFocus = FocusNode();
  TextEditingController barCodeController = TextEditingController();
  FocusNode barCodeFocus = FocusNode();
  late KeyboardVisibilityManager keyboardVisibilityManager;

  //
  bool editProd = false;
  ListenerCatBox listernerCatBox = ListenerCatBox();
  bool isLoading = false;
  //
  String? oldNameProd;
  String? oldDescriptionProd;
  String? oldPrecioProd;
  String? oldPrecioRetailProd;
  String? oldBarcode;
  String? oldStock;
  int _catID = 0;
  double ? screenWidth;
  double ? screenHeight;
  final productService = ProductService();

  void changeLockCatBox(){
    listernerCatBox.setChange(!editProd);
  }

  Future<void> updateProduct() async {
    setState(() {
      isLoading = true;
    });
    try{
      int? stock = int.tryParse(stockController.text);
      await productService.updateProductInfo(idProduct: widget.idProduct, name: nameController.text, price:  double.parse(precioController.text),
          barCod: barCodeController.text, catId: _catID, desc : descriptionController.text , cant: stock ?? 0).then((_){
        if(mounted){
          showOverlay(
              context,
              const CustomToast(
                message: 'Producto actualizado exitosamente',
              ));}
          });
      await widget.onProductModified();
    }catch(e){
      print('Error al crear producto');
      if(mounted){
        showOverlay(
            context,
            const CustomToast(
              message: 'Error al crear producto',
            ));}
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

/*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }*/
  var orientation = Orientation.portrait;
  bool isTablet = false;

  @override
  void didChangeDependencies() {
    //keyboardVisibilityManager.dispose();
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
    setState(() {
      isTablet = isTabletDevice(screenWidth!, screenHeight!, orientation);
    });
  }

  @override
  void didChangeMetrics() {
    if(mounted){
      setState(() {
        _initializeDeviceType();
      });
    }
  }

  void _initializeDeviceType() {
    // Obtener el tamaño de la pantalla desde el binding
    final window = WidgetsBinding.instance.window;
    // Obtener el factor de pixel de la pantalla
    final devicePixelRatio = window.devicePixelRatio;
    // Obtener el tamaño en pixels lógicos
    final physicalSize = window.physicalSize;
    // Convertir a tamaño lógico
    screenWidth = physicalSize.width / devicePixelRatio;
    screenHeight = physicalSize.height / devicePixelRatio;
    // Determinar la orientación
    orientation = screenWidth! > screenHeight! ? Orientation.landscape : Orientation.portrait;
    // Verificar si es tablet
    setState(() {
      isTablet = isTabletDevice(screenWidth!, screenHeight!, orientation);
      _setAllowedOrientations();
    });
  }

  void _setAllowedOrientations() {
    if (isTablet) {
      // Si es tablet, permitir todas las orientaciones
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Si no es tablet, forzar orientación vertical
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  bool isTabletDevice(double width, double height, Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return height > DeviceThresholds.minTabletHeightPortrait &&
          width > DeviceThresholds.minTabletWidth;
    } else {
      return height > DeviceThresholds.minTabletHeightLandscape &&
          width > DeviceThresholds.minTabletWidthLandscape;
    }
  }


  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    nameController.text = widget.nameProd;
    descriptionController.text = widget.descriptionProd;
    barCodeController.text = widget.barCode.toString();
    stockController.text = widget.stock.toString();
    precioController.text = widget.precio.toString();
    precioRetailController.text = widget.precioRetail.toString();
    _catID =  widget.catId;
    keyboardVisibilityManager = KeyboardVisibilityManager();
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    _initializeDeviceType();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  void onSelectedCat (int catID) {
    _catID = catID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: const Color(0xFFFFF7F6),
        body: CustomScrollView(
          physics: keyboardVisibilityManager.visibleKeyboard ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
            leadingWidth: MediaQuery.of(context).size.width,
              stretch: false,
              pinned: true,
              leading: Row(
                children: [
                  Visibility(
                      visible: editProd,
                      child: TextButton(onPressed: (){
                        setState(() {
                          editProd = false;
                        });
                      }, child: Text('Cancelar',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),), )),
                  Visibility(
                    visible: !editProd,
                    child: IconButton(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                    onPressed: () {
                      widget.onShowBlur(false);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.back,
                      size: !isTablet ? MediaQuery.of(context).size.width * 0.08 : orientation == Orientation.portrait ?
                      MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.08,
                      color: AppColors.primaryColor,
                    ),
                  ),),
                  Visibility(
                    visible: !editProd,
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0), child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          textAlign: TextAlign.start,
                          'Modificar',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: !isTablet ? screenWidth! < 370.00
                                ? MediaQuery.of(context).size.width * 0.078
                                : MediaQuery.of(context).size.width * 0.082 : orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.063 : MediaQuery.of(context).size.height * 0.063,
                            fontWeight: FontWeight.bold,
                          ),)
                      ])),),
                  const Spacer(),
                  IconButton(//onPressed del icono de modificar
                      onPressed: editProd == false ? () {
                        setState(() {
                          editProd = true;
                          changeLockCatBox();
                          oldNameProd = nameController.text;
                          oldDescriptionProd = descriptionController.text;
                          oldBarcode = barCodeController.text;
                          oldStock = stockController.text;
                          oldPrecioProd = precioController.text;
                          oldPrecioRetailProd = precioRetailController.text;
                        });
                      } : (){//onPressedDelBoton
                        setState(() {//onPresseddelGuardar
                          _catID != widget.catId || nameController.text != oldNameProd! || descriptionController.text != oldDescriptionProd! ||
                              barCodeController.text != oldBarcode! || stockController.text != oldStock! || precioController.text != oldPrecioProd!
                              || precioRetailController.text != oldPrecioRetailProd! ?
                          updateProduct() :  showOverlay(
                              context,
                              const CustomToast(
                              message: 'No se hicieron cambios',
                          ));
                          editProd = false;
                          changeLockCatBox();
                        });
                      },
                      icon: !editProd ? const Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ) : Text('Guardar ', style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),))
                ],
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
                      Column(
                        children: [
                          Column(
                            children: [
                              TitleModContainer(text: 'Nombre', isTablet: isTablet),
                              Padding(
                                  padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                              child: TextProdField(
                                inputFormatters: [
                                  RegEx(type: InputFormatterType.namesymbols),
                                ],
                                controller: nameController,
                                enabled: editProd,
                                text: 'Nombre del producto',
                              )),
                            ],
                          ),
                          Column(
                            children: [
                              TitleModContainer(text: 'Descripción', isTablet: isTablet),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: TextProdField(
                                    inputFormatters: [RegEx(type: InputFormatterType.alphanumeric)],
                                    controller: descriptionController,
                                    enabled: editProd,
                                    text: 'Descripción del producto',
                                  ))]),
                          Column(
                            children: [
                              TitleModContainer(text: 'Código de barras', isTablet: isTablet),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: TextProdField(
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      RegEx(type: InputFormatterType.numeric)],
                                    controller: barCodeController,
                                    enabled: editProd,
                                    text: 'Código del producto',
                                  ))]),
                          Column(
                            children: [
                              TitleModContainer(text: 'Categoría', isTablet: isTablet),
                              Padding(padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.03,
                                  right: MediaQuery.of(context).size.width * 0.03),
                                  child: CategoryBox(formType: 2, onSelectedCat: onSelectedCat,selectedCatId: widget.catId, listernerCatBox: listernerCatBox))]),
                          Row(
                            children: [
                              Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(
                                          top: MediaQuery.of(context).size.width * 0.04,
                                          left: MediaQuery.of(context).size.width * 0.03,
                                          right: MediaQuery.of(context).size.width * 0.03,
                                        ),
                                        height: MediaQuery.of(context).size.width * 0.09,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Text(
                                          'Cantidad',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.045 : orientation == Orientation.portrait ?
                                            MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: MediaQuery.of(context).size.width * 0.03,
                                          right: MediaQuery.of(context).size.width * 0.03,
                                        ),
                                        child: TextProdField(
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: [RegEx(type: InputFormatterType.numeric)],
                                          controller: stockController,
                                          enabled: editProd,
                                          text: 'Existencias',
                                        ),)
                                    ],
                                  )),
                            ],),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width * 0.04,
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Precio retail',
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.045 : orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                    child: TextProdField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [RegEx(type: InputFormatterType.numeric)],
                                      controller: precioRetailController,
                                      enabled: editProd,
                                      text: 'MXN',
                                    ))
                                  ],
                                )),
                              Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width * 0.04,
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                      height: MediaQuery.of(context).size.width * 0.09,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Precio de venta',
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.045 : orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.03,
                                      ),
                                    child: TextProdField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [RegEx(type: InputFormatterType.numeric)],
                                      controller: precioController,
                                      enabled: editProd,
                                      text: 'MXN',
                                    ),)
                                  ],
                                )),
                          ],),

                          SizedBox(height: editProd ? 0 : 15,),
                          Visibility(
                              visible: isLoading,
                              child: const CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              )),
                          Visibility(
                            visible: editProd,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.03,
                                  vertical: MediaQuery.of(context).size.width * 0.03,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child:  ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.whiteColor,
                                  side: const BorderSide(color: AppColors.primaryColor,),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  showDeleteProductConfirmationDialog(context, () async {
                                    await productService.deleteProduct(widget.idProduct);
                                    if (mounted) {
                                      showOverlay(
                                        context,
                                        const CustomToast(
                                          message: 'Producto eliminado',
                                        ),
                                      );
                                    }
                                    await widget.onProductDeleted();
                                  }).then((_){
                                    Navigator.pop(context);
                                  });
                                },
                                child: Text('Eliminar Producto', style: TextStyle(
                                    fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.04 : orientation == Orientation.portrait ?
                                    MediaQuery.of(context).size.width * 0.028 : MediaQuery.of(context).size.height * 0.04,
                                    color: AppColors.redDelete),),
                              ),
                            ),),
                        ],
                      )
                    ]
                )),
          ],
        )
    );
  }
}
