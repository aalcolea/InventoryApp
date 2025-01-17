import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/inventory/stock/products/views/productDetails.dart';
import 'package:provider/provider.dart';
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

class ProductsState extends State<Products> with TickerProviderStateMixin {
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
    print('pglobar $products_global');
    fetchProducts();
    widget.listenerblurr.registrarObservador((newValue){
      if(newValue == false){
        removeOverlay();
      }
    });
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

  double ? screenWidth;
  double ? screenHeight;

  @override
  void didChangeDependencies() {
    keyboardVisibilityManager.dispose();
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    widgetHeight = MediaQuery.of(context).size.height * 0.275;
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
                descripcion: products_global[index]['descripcion'],
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
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.02),
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
                                fontSize: screenWidth! < 370.00
                                    ? MediaQuery.of(context).size.width * 0.078
                                    : MediaQuery.of(context).size.width * 0.082,
                                fontWeight: FontWeight.bold,
                              ),)
                          ]))
                    ],
                  )
                ),
                /*Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.02),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors2.primaryColor,
                          )
                      ),
                      Text(
                        widget.selectedCategory,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            color: AppColors2.primaryColor
                        ),
                      ),
                    ],
                  ),
                ),*/
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.width * 0.01,
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02
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
                                  barCode: products_global[index]['barCod'] ?? '', //manejar mejor error
                                  stock: products_global[index]['cant_cart'] == null ? 0 : products_global[index]['cant_cart']['cantidad'],
                                  precio: products_global[index]['price'] ?? '',//manejar mejor error
                                  precioRetail: products_global[index]['precioRet'] ?? '0',
                                  onProductModified: () async {
                                    await refreshProducts();
                                    removeOverlay();
                                    setState(() {});
                                  },
                                  onShowBlur: widget.onShowBlur,
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
                                contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.0075, horizontal: MediaQuery.of(context).size.width * 0.0247),
                                title: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${products_global[index]['product']}",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Cant.: ",
                                              style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Text(
                                              products_global[index]['cant_cart']['cantidad'] == null ? 'Agotado' : products_global[index]['cant_cart']['cantidad'] == 0 ? 'Agotado' : '${products_global[index]['cant_cart']['cantidad']}',
                                              style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Precio: ",
                                              style: TextStyle(color: AppColors.primaryColor.withOpacity(0.5), fontSize: MediaQuery.of(context).size.width * 0.035),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Text(
                                                "\$${products_global[index]['price']} MXN",
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: MediaQuery.of(context).size.width * 0.035,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    AnimatedContainer(
                                        alignment: Alignment.bottomRight,
                                        duration: const Duration(milliseconds: 225),
                                        width: tapedIndices.contains(index) ? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.13,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: AppColors.primaryColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            AnimatedBuilder(animation: aniControllers[index],
                                                child: Visibility(
                                                  visible:  tapedIndices.contains(index),
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
                                                      size: MediaQuery.of(context).size.width * 0.07,
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
                                                size: MediaQuery.of(context).size.width * 0.07,
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
                  ),
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