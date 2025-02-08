import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/inventory/stock/products/views/productDetails.dart';
import 'package:provider/provider.dart';
import '../../../../deviceThresholds.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../kboardVisibilityManager.dart';
import '../../../sellpoint/cart/services/cartService.dart';
import '../../utils/listenerBlurr.dart';
import '../services/productsService.dart';
import '../utils/productOptions.dart';
import '../../../themes/colors.dart';

class Products extends StatefulWidget {

  final void Function(
      bool
  ) onShowBlur;

  final String selectedCategory;
  final int selectedCategoryId;
  final VoidCallback onBack;
  final Listenerblurr listenerblurr;

  const Products({super.key, required this.selectedCategory, required this.onBack, required this.selectedCategoryId, required this.onShowBlur, required this.listenerblurr});

  @override
  ProductsState createState() => ProductsState();
}

class ProductsState extends State<Products> with TickerProviderStateMixin, WidgetsBindingObserver {
  List<GlobalKey> productKeys = [];
  OverlayEntry? overlayEntry;

  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];
  late Animation<double> movLeft;
  late Animation<double> movLeftCount;
  int ? tapedIndex;
  bool isLoading = true;
  bool showBlurr = false;
  late double widgetHeight;
  late KeyboardVisibilityManager keyboardVisibilityManager;

  void itemCount (index, action){
    if(action == false){
      cantHelper[index] > 0 ? cantHelper[index]-- : cantHelper[index] = 0;
      if(cantHelper[index] == 0){
        tapedIndices.remove(index);
        aniControllers[index].reverse().then((_){
          aniControllers[index].reset();
        });
      }
    }else{
      cantHelper[index]++;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    ///RECORDAR QUITAR DEL INIT
    super.initState();
    keyboardVisibilityManager = KeyboardVisibilityManager();
    productKeys = List.generate(products_global.length, (index) => GlobalKey());
    for (int i = 0; i < products_global.length; i++) {
      aniControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 450)));
      cantHelper.add(0);
    }
    fetchProducts();
    widget.listenerblurr.registrarObservador((newValue){
      if(newValue == false){
        removeOverlay();
      }
    });
    WidgetsBinding.instance.addObserver(this);
    _initializeDeviceType();
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
    });
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



  @override
  void dispose() {
    for (var controller in aniControllers) {
      controller.dispose();
    }
    widget.listenerblurr.eliminarObservador((newValue) {
      if (mounted) {
        if (newValue == false) {
          removeOverlay();
        }
      }
    });
    super.dispose();
  }

  double? screenWidth;
  double? screenHeight;
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
    widgetHeight = MediaQuery.of(context).size.height * 0.275;
  }

  @override
  void didChangeMetrics() {
    if(mounted){
      setState(() {
        _initializeDeviceType();
      });
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final productService = ProductService();
      await productService.fetchProducts(widget.selectedCategoryId);
      setState(() {
        aniControllers = List.generate(
          products_global.length,
              (index) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 450),
          ),
        );
        cantHelper = List.generate(products_global.length, (index) => 0);
        productKeys = List.generate(products_global.length, (index) => GlobalKey());
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print('Error fetching productos: $e');
      isLoading = false;
    }
  }

  void colHeight (double _colHeight) {
    widgetHeight = _colHeight;
  }

  void showProductOptions(int index) {
    removeOverlay();
    if (index >= 0 && index < productKeys.length) {
      final key = productKeys[index];
      final RenderBox renderBox = key.currentContext
          ?.findRenderObject() as RenderBox;

      final size = renderBox.size;
      final position = renderBox.localToGlobal(Offset.zero);

      final screenHeight = MediaQuery.of(context).size.height;
      final availableSpaceBelow = screenHeight - position.dy;

      double topPosition;

      if (availableSpaceBelow >= widgetHeight) {
        topPosition = position.dy;
      } else {
        topPosition = screenHeight - widgetHeight - MediaQuery.of(context).size.height*0.03;
      }

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: topPosition - 7,
            left: position.dx,
            width: size.width,
            child: IntrinsicHeight(
              child: ProductOptions(
                onClose: removeOverlay,
                nombre: products_global[index]['product'] ?? "El producto no existe",
                cant: products_global[index]['cant_cart'] == null
                    ? 'Agotado'
                    : '${products_global[index]['cant_cart']['cantidad']}',
                precio: products_global[index]['price'],
                precioRet: products_global[index]['precioRet'],
                stock: products_global[index]['cant_cart'] == null ? 0 : products_global[index]['cant_cart']['cantidad'],
                barCode: products_global[index]['barCod'],
                catId: products_global[index]['catId'],
                id: products_global[index]['id'],
                descripcion: products_global[index]['descripcion'] ?? '',
                columnHeight: colHeight,
                onProductDeleted: () async {
                  await refreshProducts();
                  removeOverlay();
                },
                onProductModified: () async {
                  await refreshProducts();
                },
                onShowBlur: onShowBlurHandler,
                columnH: null, onShowBlureight: (bool p1) {  },
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(overlayEntry!);
      widget.onShowBlur(true);
    } else {
      print("Invalid index: $index");
    }
  }

  void onShowBlurHandler(bool shouldShow) {
    setState(() {
      showBlurr = shouldShow;
    });
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    for (var controller in aniControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
    if (mounted) {
      widget.onShowBlur(false);
    }
  }

  Future<void> refreshProducts() async {
    try {
      await fetchProducts();
      removeOverlay();
      setState(() {
        showBlurr = false;
      });
    } catch (e) {
      print('Error en refresh productos $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return isLoading ? const Material(child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor,)))
        : Scaffold(
      body: Stack(
        children: [
          Container(
            padding: !isTablet ? EdgeInsets.zero :
            orientation == Orientation.portrait ? EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.02) :
            EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02, bottom: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  leadingWidth: MediaQuery.of(context).size.width,
                  leading: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: (){
                            widget.onBack;
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primaryColor,
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0), child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              textAlign: TextAlign.start,
                              '${widget.selectedCategory}',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: !isTablet ? screenWidth! < 370.00
                                    ? MediaQuery.of(context).size.width * 0.078
                                    : MediaQuery.of(context).size.width * 0.082 : orientation == Orientation.portrait ?
                                MediaQuery.of(context).size.width * 0.074 : MediaQuery.of(context).size.height * 0.074,
                                fontWeight: FontWeight.bold,
                              ),)
                          ]))
                    ],
                  )
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      var widthItem1 = constraints.maxWidth * 0.5;
                      var widthItem2 = constraints.maxWidth * 0.7;
                      if(isTablet){
                        if(orientation == Orientation.portrait){
                          widthItem1 = constraints.maxWidth * 0.352;
                          widthItem1 = constraints.maxWidth * 0.352;
                        }else{
                          widthItem1 = constraints.maxWidth * 0.352;
                          widthItem1 = constraints.maxWidth * 0.352;
                        }
                      }
                      return ListView.builder(
                          padding: orientation == Orientation.portrait ? EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.02
                          ) : EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.01,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: products_global.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              key: productKeys[index],
                              onTap: (){
                                Navigator.push(context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProductDetails(
                                      idProduct: products_global[index]['id'],
                                      nameProd: products_global[index]['product'] ?? '',
                                      descriptionProd: products_global[index]['descripcion'] ?? '',
                                      catId: products_global[index]['catId'],
                                      barCode: products_global[index]['barCod'] ?? '',
                                      stock: products_global[index]['cant_cart'] == null ? 0 : products_global[index]['cant_cart']['cantidad'],
                                      precio: products_global[index]['price'] ?? '',
                                      precioRetail: products_global[index]['precioRet'] ?? '0',
                                      onProductModified: () async {
                                        await refreshProducts();
                                        removeOverlay();
                                        setState(() {});
                                      },
                                      onShowBlur: widget.onShowBlur,
                                      onProductDeleted: () async {  await refreshProducts(); removeOverlay();},
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                if (index >= 0 && index < products_global.length) {
                                  setState(() {
                                    showBlurr = true;
                                    showProductOptions(index);
                                  });

                                } else {
                                  print("Invalid product index: $index");
                                }
                              },
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: orientation == Orientation.portrait ? EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context).size.width * 0.0075,
                                        horizontal: MediaQuery.of(context).size.width * 0.0247) :
                                    EdgeInsets.symmetric(
                                        vertical: MediaQuery.of(context).size.height * 0.0075,
                                        horizontal: MediaQuery.of(context).size.height * 0.0247),
                                    title: Row(
                                      children: [
                                        SizedBox(
                                          width: tapedIndices.contains(index) ? widthItem1 : widthItem2,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${products_global[index]['product']}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.04 : orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 :
                                                  MediaQuery.of(context).size.height * 0.045,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Cant.: ",
                                                    style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5),
                                                      fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 :
                                                      MediaQuery.of(context).size.height * 0.04,),
                                                  ),
                                                  Text(
                                                    products_global[index]['cant_cart']['cantidad'] == null ? 'Agotado' : products_global[index]['cant_cart']['cantidad'] == 0 ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                                    style: TextStyle(
                                                      color: AppColors.primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 :
                                                      MediaQuery.of(context).size.height * 0.04,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Precio: ",
                                                    style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5),
                                                      fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 :
                                                      MediaQuery.of(context).size.height * 0.04,),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Text(
                                                      "\$${products_global[index]['price']} MXN",
                                                      style: TextStyle(
                                                        color: AppColors.primaryColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 :
                                                        MediaQuery.of(context).size.height * 0.04,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        AnimatedContainer(
                                            alignment: Alignment.bottomRight,
                                            duration: const Duration(milliseconds: 225),
                                            width: tapedIndices.contains(index) ? !isTablet ? MediaQuery.of(context).size.width * 0.3 :
                                            orientation == Orientation.portrait ?MediaQuery.of(context).size.width * 0.26 : MediaQuery.of(context).size.height * 0.32 :
                                            !isTablet ? MediaQuery.of(context).size.width * 0.13 :
                                            orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.105 : MediaQuery.of(context).size.height * 0.125,
                                            /*width: tapedIndices.contains(index) ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.13,*/
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.primaryColor,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                AnimatedBuilder(animation: aniControllers[index],
                                                    child: Visibility(
                                                      visible: tapedIndices.contains(index),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            minimumSize: const Size(0, 0),
                                                            backgroundColor: Colors.transparent,
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: MediaQuery.of(context).size.width * 0.015,
                                                              vertical: MediaQuery.of(context).size.width * 0.015,
                                                            ),
                                                            shadowColor: Colors.transparent
                                                        ),
                                                        onPressed: () {
                                                          cartProvider.decrementProductInCart(products_global[index]['product_id']);
                                                          setState(() {
                                                            bool action = false;
                                                            itemCount(index, action);
                                                          });
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons.minus,
                                                          color: AppColors.whiteColor,
                                                          size: !isTablet ? MediaQuery.of(context).size.width * 0.07 : orientation == Orientation.portrait ?
                                                          MediaQuery.of(context).size.width * 0.07 :  MediaQuery.of(context).size.height * 0.07,
                                                        ),
                                                      ),),
                                                    builder: (context, minusMove){
                                                      movLeft = Tween(begin: 0.0, end: MediaQuery.of(context).size.width * 0.023).animate(aniControllers[index]);
                                                      return Transform.translate(offset: Offset(-movLeft.value, 0), child: minusMove);
                                                    }),
                                                AnimatedBuilder(
                                                    animation: aniControllers[index],
                                                    child: Visibility(
                                                        visible: tapedIndices.contains(index),
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.primaryColor,
                                                          ),
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: MediaQuery.of(context).size.width * 0.0,
                                                            vertical: MediaQuery.of(context).size.width * 0.015,
                                                          ),
                                                          child: Text(
                                                            textAlign: TextAlign.center,
                                                            '${cantHelper[index]}',
                                                            style: TextStyle(
                                                                color: AppColors.whiteColor,
                                                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        )),
                                                    builder: (context, countMov){
                                                      movLeftCount = Tween(begin: 0.0, end: MediaQuery.of(context).size.width * 0.012).animate(aniControllers[index]);
                                                      return Transform.translate(offset: Offset(-movLeftCount.value, 0), child: countMov);
                                                    }),
                                                ///btn mas
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size(0, 0),
                                                      backgroundColor: Colors.transparent,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: MediaQuery.of(context).size.width * 0.015,
                                                        vertical: MediaQuery.of(context).size.width * 0.015,
                                                      ),
                                                      shadowColor: Colors.transparent
                                                  ),
                                                  onPressed: (products_global[index]['cant_cart']?['cantidad'] ?? 0) > cartProvider.getProductCount(products_global[index]['product_id'])
                                                      ? () {
                                                    cartProvider.addProductToCart(products_global[index]['product_id']);
                                                    setState(() {
                                                      bool action = true;
                                                      tapedIndex = index;
                                                      if (!tapedIndices.contains(index)) {
                                                        tapedIndices.add(index);
                                                      }
                                                      itemCount(index, action);
                                                      aniControllers[index].forward();
                                                    });
                                                  } : () {
                                                    showOverlay(
                                                        context,
                                                        const CustomToast(
                                                          message: 'No puedes agregar más de lo disponible en stock',
                                                        ));
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.add,
                                                    color: AppColors.whiteColor,
                                                    size: !isTablet ? MediaQuery.of(context).size.width * 0.07 : orientation == Orientation.portrait ?
                                                    MediaQuery.of(context).size.width * 0.07 :  MediaQuery.of(context).size.height * 0.07,
                                                  ),
                                                ),
                                              ],
                                            )
                                        )
                                      ],
                                    ),),
                                  Divider(
                                    indent: MediaQuery.of(context).size.width * 0.05,
                                    endIndent: MediaQuery.of(context).size.width * 0.05,
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    thickness: MediaQuery.of(context).size.width * 0.005,
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    },
                  )
                ),
              ],
            ),
          ),
          Visibility(
                       visible: showBlurr,
                       child: BackdropFilter(
                           filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                           child: GestureDetector(
                             onTap: () {
                               setState(() {
                                 showBlurr = false;
                                 removeOverlay();
                               });
                             },
                             child: Container(
                               width: double.infinity,
                               height: double.infinity,
                               color: AppColors.blackColor.withOpacity(0.3),
                             ),
                           )
                       ),
                     ),
        ],
      )

    );
  }
}