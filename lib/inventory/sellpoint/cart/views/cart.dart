import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
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

  @override
  void didChangeDependencies() {
    final cartProvider = Provider.of<CartProvider>(context);
    cantControllers.clear();
    totalCart = 0;

    for (int i = 0; i < cartProvider.cart.length; i++) {
      cantControllers.add(TextEditingController(text: cartProvider.cart[i]['cant_cart'].toStringAsFixed(0)));
      totalCart += cartProvider.cart[i]['price'] * cartProvider.cart[i]['cant_cart'];
    }
    super.didChangeDependencies();
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
                    final widthItem2 = constraints.maxWidth * 0.38;
                    return Background(widthItem1: widthItem1, widthItem2: widthItem2);/// termina codigo que sirve para el background
                  }
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.width * 0.1),
                    child: LayoutBuilder(
                        builder: (context, constraints) {
                          final widthItem1 = constraints.maxWidth * 0.352;
                          final widthItem2 = constraints.maxWidth * 0.4;
                          return ListView.builder(
                            itemCount: cartProvider.cart.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02,
                                    top: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.02
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
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                                ),
                                              ),
                                              Text(
                                                'Codigo ${cartProvider.cart[index]['product_id']}',
                                                style: TextStyle(
                                                    color: AppColors.primaryColor.withOpacity(0.3),
                                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width: widthItem2,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 0),
                                                          backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: MediaQuery.of(context).size.width * 0.02,
                                                              vertical: MediaQuery.of(context).size.width * 0.02,
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
                                                          size: MediaQuery.of(context).size.width * 0.04,
                                                        ),
                                                      ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                      child: TextFormField(
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
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 0),
                                                          backgroundColor: AppColors.primaryColor.withOpacity(0.5),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: MediaQuery.of(context).size.width * 0.02,
                                                            vertical: MediaQuery.of(context).size.width * 0.02,
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
                                                          size: MediaQuery.of(context).size.width * 0.04,
                                                        ),
                                                    )
                                                  ],
                                                ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02),
                                            alignment: Alignment.topRight,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$${(cartProvider.cart[index]['cant_cart'] * cartProvider.cart[index]['price']).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: AppColors.primaryColor,
                                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                                  ),
                                                ),
                                                Text(
                                                  'MXN',
                                                  style: TextStyle(
                                                      color: AppColors.primaryColor.withOpacity(0.3),
                                                      fontSize: MediaQuery.of(context).size.width * 0.04
                                                  ),
                                                )
                                              ],
                                            ),
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
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${totalCart.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                      ),
                    ),
                    Text(
                      'MXN ',
                      style: TextStyle(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
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
                       Platform.isAndroid ? await printService2.connectAndPrintAndroide(cartProvider.cart, 'assets/imgLog/logoTest.png') :
                        await printService2.connectAndPrintIOS(cartProvider.cart, 'assets/imgLog/logoTest.png');
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
                  fontSize: MediaQuery.of(context).size.width * 0.08,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
