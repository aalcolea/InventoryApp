import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:inventory_app/establishmentInfo.dart';
import 'package:provider/provider.dart';
import '../../../../deviceThresholds.dart';
import '../../../print/printConnections.dart';
import '../../../print/printService.dart';
import '../../../themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../stock/products/services/productsService.dart';
import '../services/cartService.dart';
import '../styles/cartStyles.dart';
import '../utils/popUpTabs/showConfirmSellDialog.dart';

class Cart extends StatefulWidget {
  final PrintService printService;
  final void Function(bool) onHideBtnsBottom;
  final Function(bool) onShowBlurr;

  final Future<void> Function()? onCartSent;
  const Cart({super.key, required this.onHideBtnsBottom, this.onCartSent, required this.printService, required this.onShowBlurr});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  //lista de prueba cambiar luego
  List<Map<String, dynamic>> carrito = [
    {'cantidad': 3, 'prod' : 'Shampo para calvos', 'precio' : 100.0, 'importe' : 20.0},
    {'cantidad': 1, 'prod' : 'Gel para barba', 'precio' : 100.0, 'importe' : 100.0},
    {'cantidad': 6, 'prod' : 'Crema hidratante', 'precio' : 150.0, 'importe' : 900.0},
    {'cantidad': 6, 'prod' : 'Crema hidratante', 'precio' : 150.0, 'importe' : 9000.0},
  ];

  List<TextEditingController> cantControllers = [];
  List<int> cantHelper = [];
  double totalCart = 0;
  PrintService printService = PrintService();
  late PrintService2 printService2;

  final FocusNode focusNode = FocusNode();
  final TextEditingController cantidadController = TextEditingController();
  late StreamSubscription<bool> keyboardVisibilitySubscription;
  late KeyboardVisibilityController keyboardVisibilityController;
  bool visibleKeyboard = false;
  int oldIndex = 0;
  double countCart = 0.0;
  void itemCount(int index, bool action, CartProvider cartProvider) {
    countCart = double.parse(cantControllers[index].text);
    if (action == false){
      cantHelper[index]--;
      if (cantHelper[index] < 0) {
        cantHelper[index] = 0;
      } else{
        cartProvider.decrementProductInCart(cartProvider.cart[index]['product_id']);
        cantControllers[index].text = cartProvider.getProductCount(cartProvider.cart[index]['product_id']).toString();
      }
      countCart = double.parse(cantControllers[index].text);
    } else{
      if (cartProvider.getProductCount(cartProvider.cart[index]['product_id']) < cartProvider.cart[index]['cant_cart']) {
        cantHelper[index]++;
        cartProvider.addProductToCart(cartProvider.cart[index]['product_id']);
        cantControllers[index].text = cartProvider.getProductCount(cartProvider.cart[index]['product_id']).toString();
      } else {
        print('No puedes agregar más de lo disponible en stock2');
      }
      countCart = double.parse(cantControllers[index].text);
    }
  }

  void checkKeyboardVisibility() {
    keyboardVisibilitySubscription =
        keyboardVisibilityController.onChange.listen((visible) {
          setState(() {
            visibleKeyboard = visible;
            widget.onHideBtnsBottom(visibleKeyboard);
          });
        });
  }

  void hideKeyBoard() {
    if (visibleKeyboard) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityController = KeyboardVisibilityController();
    checkKeyboardVisibility();
  }

  void handleAddProduct(cartProvider, index, context){
      final productInCart = cartProvider.cart.firstWhere(
            (prod) => prod['product_id'] == cartProvider.cart[index]['product_id'],
        orElse: () => <String, dynamic>{},
      );
      if (productInCart.isNotEmpty){
        final stockDisponible = productInCart['stock'];
        final cantidadEnCarrito = cartProvider.getProductCount(cartProvider.cart[index]['product_id']);
        if (cantidadEnCarrito < stockDisponible) {
          cartProvider.addProductToCart(cartProvider.cart[index]['product_id']);
          setState(() {
            bool action = true;
            itemCount(index, action, cartProvider);
          });
        } else {
          showOverlay(
            context,
            const CustomToast(
              message: 'No puedes agregar más de lo disponible en stock',
            ),
          );
        }
      } else {
        final product = products_global.firstWhere(
              (prod) => prod['product_id'] == cartProvider.cart[index]['product_id'],
          orElse: () => <String, dynamic>{},
        );
        if (product.isNotEmpty) {
          print('Producto encontrado en products_global: ${product}');
          final stockDisponible = product['cant_cart']['cantidad'] ?? 0;
          final cantidadEnCarrito = cartProvider.getProductCount(cartProvider.cart[index]['product_id']);
          if (cantidadEnCarrito < stockDisponible){
            cartProvider.addProductToCart(cartProvider.cart[index]['product_id']);
            setState(() {
              bool action = true;
              itemCount(index, action, cartProvider);
            });
          } else {
            showOverlay(
              context,
              const CustomToast(
                message: 'No puedes agregar más de lo disponible en stock',
              ),
            );
          }
        } else {
          print('Producto no encontrado en products_global');
          showOverlay(
            context,
            const CustomToast(
              message: 'Producto no encontrado en la lista de productos',
            ),
          );
        }
      }
  }

  var orientation = Orientation.portrait;
  bool isTablet = false;
  double? screenWidth;
  double? screenHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    cantControllers.clear();
    totalCart = 0;

    for (int i = 0; i < cartProvider.cart.length; i++) {
      cantControllers.add(TextEditingController(text: cartProvider.cart[i]['cant_cart'].toStringAsFixed(0)));
      totalCart += cartProvider.cart[i]['price'] * cartProvider.cart[i]['cant_cart'];
    }

    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
    isTablet = _isTabletDevice(screenWidth!, screenHeight!, orientation);
  }

  bool _isTabletDevice(double width, double height, Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return height > DeviceThresholds.minTabletHeightPortrait &&
          width > DeviceThresholds.minTabletWidth;
    } else {
      return height > DeviceThresholds.minTabletHeightLandscape &&
          width > DeviceThresholds.minTabletWidthLandscape;
    }
  }

  @override
  void dispose() {
    keyboardVisibilitySubscription.cancel();
    focusNode.dispose();
    for (var controller in cantControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      color: AppColors.bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.01,
                  left: MediaQuery.of(context).size.width * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final widthItem1 = constraints.maxWidth * 0.382;
                    var widthItem2 = orientation == Orientation.portrait ? constraints.maxWidth * 0.38 : constraints.maxWidth * 0.25;
                    return Background(widthItem1: widthItem1, widthItem2: widthItem2, orientation: orientation, isTablet: isTablet);/// termina codigo que sirve para el background
                  }
                  ),
                  Container(
                    padding: !isTablet ? EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.width * 0.1) : orientation == Orientation.portrait ?
                    EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.width * 0.1) :
                    EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02, top: MediaQuery.of(context).size.height * 0.1),
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          var widthItem1 = constraints.maxWidth * 0.352;
                          var widthItem2 = constraints.maxWidth * 0.4;
                          if(isTablet){
                            if(orientation == Orientation.portrait){
                              widthItem1 = constraints.maxWidth * 0.352;
                              widthItem2 = constraints.maxWidth * 0.38;
                            }else{
                              widthItem1 = constraints.maxWidth * 0.352;
                              widthItem2 = constraints.maxWidth * 0.25;
                            }
                          }
                          return ListView.builder(
                            itemCount: cartProvider.cart.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: !isTablet ? EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.02,
                                    top: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.02
                                    ) : orientation == Orientation.portrait ? EdgeInsets.only(
                                        left: MediaQuery.of(context).size.width * 0.02,
                                        top: MediaQuery.of(context).size.width * 0.03,
                                        right: MediaQuery.of(context).size.width * 0.02
                                    ) : EdgeInsets.only(
                                        left: MediaQuery.of(context).size.height * 0.02,
                                        top: MediaQuery.of(context).size.height * 0.03,
                                        right: MediaQuery.of(context).size.height * 0.02
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: widthItem1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${cartProvider.cart[index]['product']}',
                                                style: !isTablet ? TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                ) : TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                                ),
                                              ),
                                              Text(
                                                'Codigo ${cartProvider.cart[index]['product_id']}',
                                                style: !isTablet ? TextStyle(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                                ) : TextStyle(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: !isTablet
                                              ? const EdgeInsets.only(left: 0)
                                              : EdgeInsets.only(left: orientation == Orientation.portrait ? 3 : 15),
                                          width: widthItem2,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildQuantityButton(
                                                icon: CupertinoIcons.minus,
                                                onPressed: () {
                                                  cartProvider.decrementProductInCart(cartProvider.cart[index]['product_id']);
                                                  setState(() {
                                                    itemCount(index, false, cartProvider);
                                                  });
                                                },
                                                context: context,
                                                orientation: orientation,
                                              ),
                                              if(isTablet) const SizedBox(width: 10),
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: !isTablet
                                                      ? MediaQuery.of(context).size.width * 0.1 : orientation == Orientation.portrait
                                                      ? MediaQuery.of(context).size.width * 0.12
                                                      : MediaQuery.of(context).size.height * 0.12,
                                                ),
                                                height: !isTablet
                                                    ? MediaQuery.of(context).size.width * 0.12 : orientation == Orientation.portrait
                                                    ? MediaQuery.of(context).size.width * 0.1
                                                    : MediaQuery.of(context).size.height * 0.1,
                                                child: TextFormField(
                                                  style: TextStyle(
                                                    fontSize: orientation == Orientation.portrait
                                                        ? MediaQuery.of(context).size.width * 0.045
                                                        : MediaQuery.of(context).size.height * 0.045,
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  controller: cantControllers[index],
                                                  textAlign: TextAlign.center,
                                                  textAlignVertical: TextAlignVertical.center,
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8,
                                                    ),
                                                    isDense: true, // Reduce el padding interno
                                                    isCollapsed: true,
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(
                                                        color: AppColors.primaryColor,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide(
                                                        color: AppColors.blackColor.withOpacity(0.5),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if(isTablet) const SizedBox(width: 10),
                                              _buildQuantityButton(
                                                icon: CupertinoIcons.add,
                                                onPressed: () => handleAddProduct(cartProvider, index, context),
                                                context: context,
                                                orientation: orientation,
                                                iconSizeMultiplier: 0.045,
                                              ),
                                            ],
                                          ),
                                        ),
                                        /*Container(
                                          margin: !isTablet ? EdgeInsets.only(left: 10) : orientation == Orientation.portrait ? EdgeInsets.only(left: 3) : EdgeInsets.only(left: 15),
                                          color: Colors.blue,
                                            width: widthItem2,
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size(0, 0),
                                                      backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                                                      padding: orientation == Orientation.portrait ? EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.width * 0.02,
                                                        vertical: MediaQuery.of(context).size.width * 0.02,
                                                      ) : EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.height * 0.02,
                                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                                      ),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      cartProvider.decrementProductInCart(cartProvider.cart[index]['product_id']);
                                                      setState(() {
                                                        bool action = false;
                                                        itemCount(index, action, cartProvider);
                                                      });
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.minus,
                                                      color: AppColors.whiteColor,
                                                      size: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04
                                                          : MediaQuery.of(context).size.height * 0.04,
                                                    ),
                                                  ),
                                                  if(isTablet)... [
                                                    const SizedBox(width: 10),
                                                  ],
                                                  *//*SizedBox(
                                                    width: !isTablet ? MediaQuery.of(context).size.width * 0.12 : orientation == Orientation.portrait ?
                                                    MediaQuery.of(context).size.width * 0.09 : MediaQuery.of(context).size.width * 0.09,
                                                    child: *//*Flexible(child: TextFormField(
                                                    style: const TextStyle(
                                                        fontSize: 25
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    controller: cantControllers[index],
                                                    textAlign: TextAlign.center,
                                                    textAlignVertical: TextAlignVertical.top,
                                                    decoration: InputDecoration(
                                                      isCollapsed: true,
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: const BorderSide(
                                                          color: AppColors.primaryColor,
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide(
                                                          color: AppColors.blackColor.withOpacity(0.5),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),),
                                                  if(isTablet)... [
                                                    const SizedBox(width: 10),
                                                  ],
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size(0, 0),
                                                      backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                                                      padding: orientation == Orientation.portrait ? EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.width * 0.02,
                                                        vertical: MediaQuery.of(context).size.width * 0.02,
                                                      ) : EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.height * 0.02,
                                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                                      ),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      final productInCart = cartProvider.cart.firstWhere(
                                                            (prod) => prod['product_id'] == cartProvider.cart[index]['product_id'],
                                                        orElse: () => <String, dynamic>{},
                                                      );
                                                      if (productInCart.isNotEmpty){
                                                        final stockDisponible = productInCart['stock'];
                                                        final cantidadEnCarrito = cartProvider.getProductCount(cartProvider.cart[index]['product_id']);
                                                        if (cantidadEnCarrito < stockDisponible) {
                                                          cartProvider.addProductToCart(cartProvider.cart[index]['product_id']);
                                                          setState(() {
                                                            bool action = true;
                                                            itemCount(index, action, cartProvider);
                                                          });
                                                        } else {
                                                          showOverlay(
                                                            context,
                                                            const CustomToast(
                                                              message: 'No puedes agregar más de lo disponible en stock',
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        final product = products_global.firstWhere(
                                                              (prod) => prod['product_id'] == cartProvider.cart[index]['product_id'],
                                                          orElse: () => <String, dynamic>{},
                                                        );
                                                        if (product.isNotEmpty) {
                                                          print('Producto encontrado en products_global: ${product}');
                                                          final stockDisponible = product['cant_cart']['cantidad'] ?? 0;
                                                          final cantidadEnCarrito = cartProvider.getProductCount(cartProvider.cart[index]['product_id']);
                                                          if (cantidadEnCarrito < stockDisponible){
                                                            cartProvider.addProductToCart(cartProvider.cart[index]['product_id']);
                                                            setState(() {
                                                              bool action = true;
                                                              itemCount(index, action, cartProvider);
                                                            });
                                                          } else {
                                                            showOverlay(
                                                              context,
                                                              const CustomToast(
                                                                message: 'No puedes agregar más de lo disponible en stock',
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          print('Producto no encontrado en products_global');
                                                          showOverlay(
                                                            context,
                                                            const CustomToast(
                                                              message: 'Producto no encontrado en la lista de productos',
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: Icon(
                                                      CupertinoIcons.add,
                                                      color: AppColors.whiteColor,
                                                      size: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.045
                                                          : MediaQuery.of(context).size.height * 0.045,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        ),*/
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '\$${(cartProvider.cart[index]['cant_cart'] * cartProvider.cart[index]['price']).toStringAsFixed(2)}',
                                                style: !isTablet ? TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                ) : TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                                ),
                                              ),
                                              Text(
                                                'MXN',
                                                style: !isTablet ? TextStyle(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                                ) : TextStyle(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                    ),
                  )
                ],
              ),
            ),
          ),
          if(orientation == Orientation.landscape)...[
            Padding(padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.03,
                right: MediaQuery.of(context).size.width * 0.03,
            ), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: !isTablet ? TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                  ) : TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.055,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${totalCart.toStringAsFixed(2)}',
                      style: !isTablet ? TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                      ) : TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.055,
                      ),
                    ),
                    Text(
                      ' MXN ',
                      style: !isTablet ? TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ) : TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.height * 0.03,
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.primaryColor,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02,
                          horizontal: MediaQuery.of(context).size.height * 0.05)
                  ),
                  onPressed: cartProvider.cart.isNotEmpty ? () async {
                    widget.onShowBlurr(true);
                    final confirmData = await showConfirmSellDialog(context);
                    if (confirmData != null) {
                      bool isCardPayment = confirmData['isCardPayment'] ?? false;
                      bool canPrint = false;
                      try{
                        await widget.printService.ensureCharacteristicAvailable();
                        if(widget.printService.characteristic != null){
                          canPrint = true;
                        }
                      }catch(e){
                        print("Error: No hay impresora conectada  - $e");
                        showOverlay(context, const CustomToast(message: 'Impresion no disponible, continuando con la venta'));
                      }
                      if(canPrint){
                        PrintService2 printService2 = PrintService2(widget.printService.characteristic!);
                        try{
                          Platform.isAndroid ? await printService2.connectAndPrintAndroide(cartProvider.cart, Establishmentinfo.logoRootAsset, Establishmentinfo.logo) :
                          await printService2.connectAndPrintIOS(cartProvider.cart, Establishmentinfo.logoRootAsset, Establishmentinfo.logo);
                        } catch(e){
                          print("Error al intentar imprimir: $e");
                          showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                        }
                      }
                      bool result = await cartProvider.sendCart(isCardPayment);
                      widget.onShowBlurr(false);
                      if(result){
                        showOverlay(context, const CustomToast(message: 'Venta efectuada correctamente'));
                        cartProvider.refreshCart();
                      }else{
                        showOverlay(context, const CustomToast(message: 'Error al efectuar la venta'));
                      }
                    }else{
                      widget.onShowBlurr(false);
                    }
                  } : null,
                  child: Text(
                    'Pagar',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: MediaQuery.of(context).size.height * 0.04,
                    ),
                  ),
                ),
              ],
            ),)
          ],
          if(orientation == Orientation.portrait)...[
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.03,
                  right: MediaQuery.of(context).size.width * 0.03,
                  top: MediaQuery.of(context).size.width * 0.02,
                  bottom: MediaQuery.of(context).size.width * 0.01
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total:',
                    style: !isTablet ? TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                    ) : TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.055,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${totalCart.toStringAsFixed(2)}',
                        style: !isTablet ? TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.08,
                        ) : TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.055 : MediaQuery.of(context).size.height * 0.055,
                        ),
                      ),
                      Text(
                        'MXN ',
                        style: !isTablet ? TextStyle(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ) : TextStyle(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          fontWeight: FontWeight.bold,
                          fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.height * 0.03,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
          if(orientation == Orientation.portrait)... [
            Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.01),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.08)
                ),
                onPressed: cartProvider.cart.isNotEmpty ? () async {
                  widget.onShowBlurr(true);
                  final confirmData = await showConfirmSellDialog(context);
                  if (confirmData != null) {
                    bool isCardPayment = confirmData['isCardPayment'] ?? false;
                    bool canPrint = false;
                    try{
                      await widget.printService.ensureCharacteristicAvailable();
                      if(widget.printService.characteristic != null){
                        canPrint = true;
                      }
                    }catch(e){
                      print("Error: No hay impresora conectada  - $e");
                      showOverlay(context, const CustomToast(message: 'Impresion no disponible, continuando con la venta'));
                    }
                    if(canPrint){
                      PrintService2 printService2 = PrintService2(widget.printService.characteristic!);
                      try{
                        Platform.isAndroid ? await printService2.connectAndPrintAndroide(cartProvider.cart, Establishmentinfo.logoRootAsset, Establishmentinfo.logo) :
                        await printService2.connectAndPrintIOS(cartProvider.cart, Establishmentinfo.logoRootAsset, Establishmentinfo.logo);
                      } catch(e){
                        print("Error al intentar imprimir: $e");
                        showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                      }
                    }
                    bool result = await cartProvider.sendCart(isCardPayment);
                    widget.onShowBlurr(false);
                    if(result){
                      showOverlay(context, const CustomToast(message: 'Venta efectuada correctamente'));
                      cartProvider.refreshCart();
                    }else{
                      showOverlay(context, const CustomToast(message: 'Error al efectuar la venta'));
                    }
                  }else{
                    widget.onShowBlurr(false);
                  }
                } : null,
                child: Text(
                  'Pagar',
                  style: !isTablet ? TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                  ) : TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
    required Orientation orientation,
    double iconSizeMultiplier = 0.04,
  }) {
    return SizedBox(
      height: !isTablet ? MediaQuery.of(context).size.width * 0.12 : orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width * 0.1
          : MediaQuery.of(context).size.height * 0.1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 0),
          backgroundColor: AppColors.primaryColor.withOpacity(0.5),
          padding: orientation == Orientation.portrait
              ? EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.width * 0.02,
          )
              : EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: AppColors.whiteColor,
          size: orientation == Orientation.portrait
              ? MediaQuery.of(context).size.width * iconSizeMultiplier
              : MediaQuery.of(context).size.height * iconSizeMultiplier,
        ),
      ),
    );
  }
}
