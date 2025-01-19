import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/inventory/stock/products/services/productsService.dart';
import 'package:inventory_app/inventory/stock/products/utils/productOptions.dart';
import 'package:inventory_app/inventory/stock/products/views/productDetails.dart';
import 'package:inventory_app/inventory/stock/utils/listenerBlurr.dart';
import 'package:provider/provider.dart';
import '../../helpers/utils/showToast.dart';
import '../../helpers/utils/toastWidget.dart';
import '../admin.dart';
import '../kboardVisibilityManager.dart';
import '../sellpoint/cart/services/cartService.dart';
import '../sellpoint/cart/services/searchService.dart';
import '../themes/colors.dart';
import 'package:http/http.dart' as http;
import 'products/views/products.dart';

class Seeker extends StatefulWidget {

  final void Function(
      bool,
      ) onShowBlur;
  final Listenerblurr listenerblurr;

  const Seeker({super.key, required this.onShowBlur, required this.listenerblurr,});

  @override
  State<Seeker> createState() => _SeekerState();
}

class _SeekerState extends State<Seeker> with TickerProviderStateMixin {
  ///comnfiguracion alan
  GlobalKey<ProductsState> productsKey = GlobalKey<ProductsState>();
  bool isLoading = false;
  final SearchService searchService = SearchService();
  List<dynamic> categories = [];
  List<dynamic> productos = [];
  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<GlobalKey> productKeys = [];
  int ? tapedIndex;

  void changeBlurr(){
    if (productsKey.currentState != null) {
      productsKey.currentState!.removeOverlay();
    }
    widget.listenerblurr.setChange(false);
  }

  Future<void> searchProductsAndCategories(String searchTerm) async {
    if (searchTerm.isEmpty) {
      setState(() {
        categories = [];
        productos = [];
      });
      return;
    }
    setState(() => isLoading = true);
    try {
      final data = await searchService.searchProductsAndCategories(searchTerm);
      if (searchController.text == searchTerm) {
        setState(() {
          categories = data['categories'];
          productos = data['productos'];
        });
      }
      productKeys = List.generate(productos.length, (index) => GlobalKey());
      for (int i = 0; i < productos.length; i++) {
        aniControllers.add(AnimationController(vsync: this, duration: const Duration(milliseconds: 450)));
        cantHelper.add(0);
      }
    } catch (e) {
      print('error: $e');
    } finally {
      if (searchController.text == searchTerm) {
        setState(() => isLoading = false);
      }
    }
  }

  /// finaliza
  late KeyboardVisibilityManager keyboardVisibilityManager;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  double? screenWidth;
  bool hasMoreItems = true;
  final String baseURL = 'https://inventorioapp-ea98995372d9.herokuapp.com/api/categories';
  late int selectedCategoryId;
  String? _selectedCategory;
  OverlayEntry? overlayEntry;
  double widgetHeight = 0.0;
  bool showBlurr = false;
  List<int> tapedIndices = [];
  late Animation<double> movLeft;
  late Animation<double> movLeftCount;

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
    keyboardVisibilityManager = KeyboardVisibilityManager();
    //loadFirstItems();
    //fetchProducts();
    widget.listenerblurr.registrarObservador((newValue){
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  int limit = 6;
  int offset = 0;
  List<Map<String, dynamic>> items = [];
  Future<void> loadFirstItems() async{
    try{
      setState(() {
        items.clear();
        offset = 0;
        hasMoreItems = true;
      });
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        items = fetchedItems;
        offset += limit;
      });
      _ensureAddCatAtTheEnd();
    }catch(e){
      print('Error al cargar los items $e');
    }
  }
  Future<void> loadItems() async{
    if (!hasMoreItems) return;
    try{
      List<Map<String, dynamic>> fetchedItems = await fetchItems(limit: limit, offset: offset);
      setState(() {
        // Only add new items that don't already exist in the items list
        for (var newItem in fetchedItems) {
          bool exists = items.any((item) => item['id'] == newItem['id']);
          if (!exists) {
            items.add(newItem);
          }
        }

        if (fetchedItems.length < limit) {
          hasMoreItems = false; // No more items to load
        }
        offset += limit;
      });
      _ensureAddCatAtTheEnd();
    }catch(e){
      print('Error al cargar mas productos $e');
    }
  }

  void _clearSelectedCategory() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _ensureAddCatAtTheEnd() {
    items.removeWhere((item) => item['category'] == 'addCat');
    for (int i = 5; i <= items.length; i += 6) {
      items.insert(i, {'category': 'addCat', 'id': 'addCat'});
    }
    if (items.length % 6 != 0) {
      items.add({'category': 'addCat', 'id': 'addCat'});
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems({int limit = 6, int offset = 0}) async{
    final response = await http.get(Uri.parse(baseURL + '?limit=$limit&offset=$offset'));
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item){
        return {
          'id' : item['id'],
          'category': item['nombre'],
          'image': item['foto'],
        };
      }).toList();
    }else{
      throw Exception('Error al obtener datos de la API');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final productService = ProductService();
      await productService.fetchProducts(selectedCategoryId);
      setState(() {
        cantHelper = List.generate(productos.length, (index) => 0);
        productKeys = List.generate(productos.length, (index) => GlobalKey());
        aniControllers = List.generate(
          productos.length,
              (index) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 450),
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching productos: $e');
      isLoading = false;
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

  void colHeight (double _colHeight) {
    widgetHeight = _colHeight;
  }

  void showProductOptions(int index) {
    removeOverlay();
    print(productKeys.length);
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
                nombre: productos[index]['nombre'] ?? "El producto no existe",
                cant: productos[index]['stock']['cantidad'] == null
                    ? 'Agotado'
                    : '${productos[index]['stock']['cantidad']}',
                precio: double.parse(productos[index]['precio']),
                precioRet: double.parse(productos[index]['precioRet']),
                stock: productos[index]['stock']['cantidad'] ?? 0,
                barCode: productos[index]['codigo_barras'],
                catId: productos[index]['category_id'],
                id: productos[index]['id'],
                descripcion: productos[index]['descripcion'],
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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    int itemsPerPage = 6;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Stack(
        children: [
          Container(
            color: AppColors.whiteColor,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.047),
            child: Column(
              children: [
                Row(
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
                    Text(
                      'Buscar',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: screenWidth! < 370.00
                            ? MediaQuery.of(context).size.width * 0.078
                            : MediaQuery.of(context).size.width * 0.082,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                            height: MediaQuery.of(context).size.width * 0.105,//37
                            child: TextFormField(
                              controller: searchController,
                              focusNode: focusNode,
                              autofocus: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Buscar producto...',
                                hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.2)
                                ),
                                prefixIcon: Icon(Icons.search, color: AppColors.primaryColor.withOpacity(0.2)),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon: searchController.text.isNotEmpty ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    searchProductsAndCategories('');
                                  },
                                  icon: Icon(
                                    CupertinoIcons.clear,
                                    size: MediaQuery.of(context).size.width * 0.05,
                                    color: AppColors.primaryColor,
                                  ),
                                ) : null
                              ),
                              ///test alan
                              onChanged: (value) {
                              searchProductsAndCategories(value);
                            },
                              ///final onchange alan
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: categories.isNotEmpty ? true : false,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                        child: Text(
                          'Categorias',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: screenWidth! < 370.00
                                ? MediaQuery.of(context).size.width * 0.07
                                : MediaQuery.of(context).size.width * 0.075,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (categories.length / itemsPerPage).ceil(),
                            itemBuilder: (context, pageIndex) {
                              int startIndex = pageIndex * itemsPerPage;
                              int endIndex = startIndex + itemsPerPage - 1;
                              if (endIndex > categories.length) {
                                endIndex = categories.length;
                              }
                              var currentPageItems = categories.sublist(startIndex, endIndex);
                              return GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      mainAxisExtent: MediaQuery.of(context).size.width * 0.5
                                  ),
                                  itemCount: currentPageItems.length,
                                  itemBuilder: (context, index) {
                                    var item = currentPageItems[index];
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedCategoryId = categories[index]['id'];
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) => Products(selectedCategory: categories[index]['nombre'].toString(), onBack: _clearSelectedCategory, selectedCategoryId: selectedCategoryId, onShowBlur: widget.onShowBlur,listenerblurr: widget.listenerblurr),
                                            ),
                                          );
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(1),
                                              decoration: BoxDecoration(
                                                color: AppColors.whiteColor,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.blackColor.withOpacity(0.3),
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 5,
                                                    spreadRadius: 0.1,
                                                  )
                                                ],
                                              ),
                                              height: MediaQuery.of(context).size.width * 0.35,
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Image.network(
                                                      categories[index]['foto'],
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
                                                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                                        return const Text('Error al cargar la imagen');
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Text(
                                                "${categories[index]['nombre']}",
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: MediaQuery.of(context).size.height * 0.017,
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: productos.isNotEmpty ? true : false,
                  child: Expanded(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
                          child: Text(
                            'Productos',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: screenWidth! < 370.00
                                  ? MediaQuery.of(context).size.width * 0.07
                                  : MediaQuery.of(context).size.width * 0.075,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.width * 0.01,
                                left: MediaQuery.of(context).size.width * 0.02,
                                right: MediaQuery.of(context).size.width * 0.02
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: productos.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                key: productKeys.isNotEmpty && productKeys.length > index ? productKeys[index] : null,
                                onTap: () {
                                  Navigator.push(context,
                                    CupertinoPageRoute(
                                      builder: (context) => ProductDetails(
                                        idProduct: productos[index]['id'],
                                        nameProd: productos[index]['nombre'],
                                        descriptionProd: productos[index]['descripcion'],
                                        catId: productos[index]['category_id'] ?? 0,
                                        barCode: productos[index]['codigo_barras'],
                                        stock: productos[index]['stock']['cantidad'] ?? 0,
                                        precio: double.parse(productos[index]['precio']),
                                        precioRetail: double.parse(productos[index]['precioRet'] ?? '0'),
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
                                  setState(() {
                                    showBlurr = true;
                                    showProductOptions(index);
                                  });
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
                                                "${productos[index]['nombre']}",
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
                                                    productos[index]['stock']['cantidad'] == null ? 'Agotado' : productos[index]['stock']['cantidad'] == 0 ? 'Agotado' : '${productos[index]['stock']['cantidad']}',
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
                                                      "\$${productos[index]['precio']} MXN",
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
                                                            cartProvider.decrementProductInCart(productos[index]['id']);
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
                                                    onPressed: (productos[index]['stock']?['cantidad'] ?? 0) > cartProvider.getProductCount(productos[index]['id'])
                                                        ? () {
                                                      productsGlobalTemp = (productos as List).map((item) => item as Map<String, dynamic>).toList();
                                                      final product_id = productsGlobalTemp[index]['id'];
                                                      Provider.of<CartProvider>(context, listen: false).addProductToCart(product_id, isFromBarCode: true);
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
                                      ),
                                    ),
                                    Divider(
                                      indent: MediaQuery.of(context).size.width * 0.05,
                                      endIndent: MediaQuery.of(context).size.width * 0.05,
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      thickness: MediaQuery.of(context).size.width * 0.005,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ],
            )
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
                      changeBlurr();
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
