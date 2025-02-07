import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import '../../../scanBarCode.dart';
import '../../../themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../../regEx.dart';
import '../../../kboardVisibilityManager.dart';
import '../../categories/forms/categoryBox.dart';
import '../services/productsService.dart';
import '../styles/productFormStyles.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({super.key});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {

  late KeyboardVisibilityManager keyboardVisibilityManager;

  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController descriptionController = TextEditingController();
  FocusNode descriptionFocus = FocusNode();
  TextEditingController precioRetailController = TextEditingController();
  FocusNode precioRetailFocus = FocusNode();
  TextEditingController barCodeController = TextEditingController();
  FocusNode barCodeFocus = FocusNode();
  TextEditingController precioPublico = TextEditingController();
  FocusNode precioPublicoFocus = FocusNode();
  TextEditingController existenciasController = TextEditingController();
  FocusNode existenciasFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  //
  double ? screenWidth;
  double ? screenHeight;
  int _catID = 0;
  bool isLoading = false;
  bool helperCloseScan = false;
  bool isValidationActive = false;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  void changeFocus(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void look4EmpFields (){
    _formKey.currentState?.validate();
  }

  void addTextListeners(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.addListener(() {
        setState(() {
          isValidationActive ? look4EmpFields() : null;
        });
      });
    }
  }

  @override
  void initState() {
    existenciasController.text = '1';
    keyboardVisibilityManager = KeyboardVisibilityManager();
    addTextListeners([nameController, precioRetailController, precioPublico, barCodeController, existenciasController]);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  void onScanProd(String? resultScanedProd) async {
    if(!helperCloseScan && resultScanedProd != null){
      setState(() {
        helperCloseScan = true;
        barCodeController.text = resultScanedProd;
      });
      await soundScaner().then((_) async {
        if(mounted) Navigator.of(context).pop();
        await Future.delayed(const Duration(milliseconds: 400));
        helperCloseScan = false;
      });
    }
  }

  final productService = ProductService();

  Future<void> createProduct() async {
    isValidationActive = true;

    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      print("Por favor complete todos los campos obligatorios");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Llamada al servicio para crear el producto
      await productService
          .createProduct(
        nombre: nameController.text,
        precio: double.parse(precioPublico.text),
        codigoBarras: barCodeController.text,
        descripcion: descriptionController.text,
        categoryId: _catID,
        precioRet: double.parse(precioRetailController.text),
        cant: int.parse(existenciasController.text)
      )
          .then((_) {
        if (mounted) {
          showOverlay(
            context,
            const CustomToast(
              message: 'Producto creado exitosamente',
            ),
          );
        }
      });

      print('Producto creado exitosamente');
      Navigator.pop(context, true);
    } catch (e) {
      print('Error al crear producto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSelectedCat (int catID) {
    _catID = catID;
    isValidationActive ? look4EmpFields() : null;
  }


  Future<void> soundScaner() async {
    Soundpool pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
    int soundId = await rootBundle.load('assets/sounds/store_scan.mp3').then((ByteData soundData){
      return pool.load(soundData);
    });
    int streamId = await pool.play(soundId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            leadingWidth: MediaQuery.of(context).size.width,
            backgroundColor: AppColors.whiteColor,
            stretch: false,
            pinned: true,
            leading: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.back,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: AppColors.primaryColor,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0), child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          textAlign: TextAlign.start,
                          'Agregar Producto',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: screenWidth! < 370.00
                              ? MediaQuery.of(context).size.width * 0.078
                              : MediaQuery.of(context).size.width * 0.082,
                          fontWeight: FontWeight.bold,
                        ),)
                    ]))
              ],
            ),
             ),
        SliverList(
            delegate: SliverChildListDelegate(
            [
             Form(
               key: _formKey,
               child: Column(
               children: [
                 Column(
                   children: [
                     TitleModContainer(text: 'Nombre', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: nameFocus,
                           controller: nameController,
                           inputFormatters: [
                             RegEx(type: InputFormatterType.alphanumeric),
                           ],
                           text: 'Nombre del producto',
                           textStyle: const TextStyle(
                             color: AppColors.primaryColor,
                           ),
                           onEditingComplete: () => changeFocus(context, nameFocus, descriptionFocus),
                           validator: (value) {
                             if (value == null || value.isEmpty) {
                               return 'El nombre es obligatorio';
                             }
                             if (value.length <= 2) {
                               return 'El nombre debe tener al menos 3 caracteres';
                             }
                             return null;
                           },
                         )),
                   ],
                 ),

                 Column(
                   children: [
                     TitleModContainer(text: 'Descripción', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: descriptionFocus,
                           controller: descriptionController,
                           inputFormatters: [
                             RegEx(type: InputFormatterType.alphanumeric),
                           ],
                           text: 'Descripción del producto',
                           textStyle: const TextStyle(
                             color: AppColors.primaryColor,
                           ),
                           onEditingComplete: () => changeFocus(context, descriptionFocus, precioRetailFocus),
                         )),
                   ],
                 ),

                 Column(
                   children: [
                     TitleModContainer(text: 'Precio del proveedor', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: precioRetailFocus,
                           controller: precioRetailController,
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           text: 'Precio del producto retail',
                           textStyle: const TextStyle(
                             color: AppColors.primaryColor,
                           ),
                           onEditingComplete: () => changeFocus(context, precioRetailFocus, precioPublicoFocus),
                           validator: (value) {
                             if (value == null || value.isEmpty) {
                               return 'El precio es obligatorio';
                             }
                             return null;
                           },
                         )),
                   ],
                 ),
                 Column(
                   children: [
                     TitleModContainer(text: 'Precio al público', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: precioPublicoFocus,
                           controller: precioPublico,
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           text: 'Precio de venta al público',
                           textStyle: const TextStyle(
                             color: AppColors.primaryColor,
                           ),
                           onEditingComplete: () => changeFocus(context, precioPublicoFocus, barCodeFocus),
                           validator: (value) {
                             if (value == null || value.isEmpty) {
                               return 'El precio es obligatorio';
                             }
                             return null;
                           },
                         )),
                   ],
                 ),
                 Column(
                   children: [
                     TitleModContainer(text: 'Código de barras'),
                     Padding(
                       padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                       child: Builder(builder: (context){
                         return TextField(
                           focusNode: barCodeFocus,
                           controller: barCodeController,
                           keyboardType: TextInputType.number,
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           decoration: InputDecoration(
                             hintText: 'Código de barras del producto',
                             hintStyle: const TextStyle(color: AppColors.primaryColor),
                             suffixIcon: IconButton(
                               icon: const Icon(Icons.qr_code_scanner, color: AppColors.primaryColor),
                               onPressed: () {
                                 showModalBottomSheet(
                                   context: context ,
                                   isScrollControlled: true,
                                   builder: (BuildContext context) {
                                     return ScanBarCode(
                                         onShowScan: (show) {
                                           Navigator.of(context).pop();
                                         },
                                         onScanProd: onScanProd
                                     );
                                   },
                                 ).then((_) async {
                                   await Future.delayed(const Duration(milliseconds: 150));
                                   //helperCloseScan = false;
                                 });
                               },
                             ),
                             enabledBorder: const OutlineInputBorder(
                               borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                               borderRadius: BorderRadius.only(
                                 bottomLeft: Radius.circular(10),
                                 bottomRight: Radius.circular(10),
                               ),
                             ),
                             focusedBorder: const OutlineInputBorder(
                               borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
                               borderRadius: BorderRadius.only(
                                 bottomLeft: Radius.circular(10),
                                 bottomRight: Radius.circular(10),
                               ),
                             ),
                           ),
                           style: const TextStyle(color: AppColors.primaryColor),
                         );
                       }),
                     ),
                   ],
                 ),
                 Column(
                   children: [
                     TitleModContainer(text: 'Existencias', ),
                     Padding(
                         padding: EdgeInsets.only(
                             left: MediaQuery.of(context).size.width * 0.03,
                             right: MediaQuery.of(context).size.width * 0.03),
                         child: TextProdField(
                           focusNode: existenciasFocus,
                           controller: existenciasController,
                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                           inputFormatters: [
                             RegEx(type: InputFormatterType.numeric),
                           ],
                           text: 'Existencias en el establecimiento',
                           textStyle: const TextStyle(
                             color: AppColors.primaryColor,
                           ),
                           onEditingComplete: () => changeFocus(context, precioPublicoFocus, barCodeFocus),
                           validator: (value) {//TODO checar que es mejor para los productos agranel
                             if (value == '0' || value == null || value.isEmpty) {
                               return 'Existencias no puede ser 0';
                             }
                             return null;
                           },)),
                   ],
                 ),

                 Column(
                     children: [
                       TitleModContainer(text: 'Categoria'),
                       Padding(padding: EdgeInsets.only(
                           left: MediaQuery.of(context).size.width * 0.03,
                           right: MediaQuery.of(context).size.width * 0.03),
                           child: CategoryBox(formType: 1, onSelectedCat: onSelectedCat))]),

                 Padding(padding: EdgeInsets.only(
                   top: MediaQuery.of(context).size.width * 0.07,
                   bottom: MediaQuery.of(context).size.width * 0.1,
                   left: MediaQuery.of(context).size.width * 0.03,
                   right: MediaQuery.of(context).size.width * 0.03,
                 ),
                   child: ElevatedButton(
                     onPressed: createProduct,
                     style: ElevatedButton.styleFrom(
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10),
                       ),
                       backgroundColor: AppColors.primaryColor,
                       padding: EdgeInsets.symmetric(
                         horizontal: MediaQuery.of(context).size.width * 0.15,
                         vertical: MediaQuery.of(context).size.width * 0.03,
                       ),
                     ), child: !isLoading ? Text('Crear Producto', style: TextStyle(
                       fontSize: MediaQuery.of(context).size.width * 0.06,
                       color: AppColors.whiteColor
                   ),) : const CircularProgressIndicator(color: Colors.white,),
                   ),),

               ],
             ),),
            ]
          )),
        ],
      )
    );
  }
}
