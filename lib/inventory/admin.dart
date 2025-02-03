import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory_app/inventory/print/printConnections.dart';
import 'package:inventory_app/inventory/scanBarCode.dart';
import 'package:inventory_app/inventory/sellpoint/cart/services/cartService.dart';
import 'package:inventory_app/inventory/sellpoint/cart/services/scannerService.dart';
import 'package:inventory_app/inventory/sellpoint/cart/services/searchService.dart';
import 'package:inventory_app/inventory/sellpoint/cart/views/cart.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/salesHistory.dart';
import 'package:inventory_app/inventory/stock/categories/views/categories.dart';
import 'package:inventory_app/inventory/stock/products/forms/productForm.dart';
import 'package:inventory_app/inventory/stock/products/views/products.dart';
import 'package:inventory_app/inventory/stock/searchBar.dart';
import 'package:inventory_app/inventory/stock/utils/listenerBlurr.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';
import '../deviceThresholds.dart';
import '../helpers/utils/PopUpTabs/closeConfirm.dart';
import '../navBar.dart';
import 'deviceManager.dart';
import 'kboardVisibilityManager.dart';
import 'listenerPrintService.dart';
import 'themes/colors.dart';

class adminInv extends StatefulWidget {
  const adminInv({super.key});

  @override
  State<adminInv> createState() => _adminInvState();
}

List<Map<String, dynamic>> productsGlobalTemp = [];
//agregar el tmepo a servicio igual
class _adminInvState extends State<adminInv> with WidgetsBindingObserver {
  GlobalKey<ProductsState> productsKey = GlobalKey<ProductsState>();
  PrintService printService = PrintService();
  bool _showBlurr = false;
  String currentScreen = "inventario";
  double? screenWidth;
  double? screenHeight;
  int _selectedScreen = 1;
  bool _hideBtnsBottom = false;
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool showScaner = false;
  String? scanedProd;
  Soundpool? pool;
  final Listenerblurr _listenerblurr = Listenerblurr();
  late KeyboardVisibilityManager keyboardVisibilityManager;
  bool _cancelConfirm = false;
  ///variables search
  final SearchService searchService = SearchService();
  bool isSearching = false;
  List<String> searchedBarcodes = [];
  List<dynamic> producto = []; ///despues le quito la lista (alan)
  bool lockScreen = false;
  ListenerPrintService listenerPrintService = ListenerPrintService();
  /// instancia de auto search
  final scannerService = BarcodeScannerService();
  bool prodInexistente = false;


  void changeBlurr(){
    if (productsKey.currentState != null) {
      productsKey.currentState!.removeOverlay();
    }
    _listenerblurr.setChange(false);
  }

  void onHideBtnsBottom(bool hideBtnsBottom) {
    setState(() {
      _hideBtnsBottom = hideBtnsBottom;
    });
  }

  Future<void> soundScaner() async {
    Soundpool pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
    int soundId = await rootBundle.load('assets/sounds/store_scan.mp3').then((ByteData soundData){
      return pool.load(soundData);
    });
    int streamId = await pool.play(soundId);
  }

  void _onShowBlur(bool showBlur){
    if (mounted) {
      setState(() {
        _showBlurr = showBlur;
      });
    }
  }

  void onShowScan(bool closeScan){
    setState(() {
      showScaner = closeScan;
    });
  }
  void onScanProd(String? resultScanedProd) async {
    print('result $resultScanedProd');
    if (resultScanedProd == null || resultScanedProd.isEmpty || isSearching) {
      print("Código inválido o búsqueda en progreso");
      return;
    }
    scanedProd = resultScanedProd;
    showScaner = false;
    isSearching = true;
    try {
      final productFound = await searchProductByBCode(scanedProd);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 700),
            padding: !deviceInfo.isTablet ? EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.08,
              bottom: MediaQuery.of(context).size.width * 0.08,
              left: MediaQuery.of(context).size.width * 0.02,
            ) : orientation == Orientation.portrait ? EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.08,
              bottom: MediaQuery.of(context).size.width * 0.08,
              left: MediaQuery.of(context).size.width * 0.02,
            ) :
            EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.08,
              bottom: MediaQuery.of(context).size.height * 0.08,
              left: MediaQuery.of(context).size.height * 0.02,
            ),
            backgroundColor: productFound ? Colors.green : Colors.redAccent,
            content: Text(
              productFound
                  ? 'Producto agregado al carrito'
                  : 'Producto agotado',
              style: TextStyle(
                color: Colors.white,
                fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.045 : orientation == Orientation.portrait ?
                MediaQuery.of(context).size.width * 0.042 :  MediaQuery.of(context).size.height * 0.042,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error en la búsqueda: $e');
    } finally {
      soundScaner();
      isSearching = false;
    }
  }

  /// Busca el producto por código de barras y retorna si se encontró o no.
  Future<bool> searchProductByBCode(String? barcode) async {
    print('searchProductByBCode $barcode');
    if (barcode == null || barcode.isEmpty) {
      setState(() {
        producto = [];
      });
      return false;
    }
    try {
      final barcodeVariants = BarcodeScannerService().getBarcodeVariants(barcode);
      for (final variant in barcodeVariants) {
        final data = await searchService.searchByBCode(variant);
        productsGlobalTemp = (data['productos'] as List)
            .map((item) => item as Map<String, dynamic>).toList();
        if (productsGlobalTemp.isNotEmpty) {
          final product = productsGlobalTemp[0];
          final int stock = product['stock']['cantidad'] ?? 0;
          if (stock > 0) {
            int currentQTT = Provider.of<CartProvider>(context, listen: false).getProductCount(product['id']);
            if(stock == currentQTT){
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 700),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.08,
                      bottom: MediaQuery.of(context).size.width * 0.08,
                      left: MediaQuery.of(context).size.width * 0.02,
                    ),
                    backgroundColor: Colors.orangeAccent,
                    content: Text(
                      'Ya no puedes agregar más de este producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                      ),
                    ),
                  ),
                );
                return false;
              }

            }else{
              final productId = product['id'];
              Provider.of<CartProvider>(context, listen: false).addProductToCart(productId, isFromBarCode: true);
              return true;
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 700),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.08,
                    bottom: MediaQuery.of(context).size.width * 0.08,
                    left: MediaQuery.of(context).size.width * 0.02,
                  ),
                  backgroundColor: Colors.orangeAccent,
                  content: Text(
                    'Producto agotado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                    ),
                  ),
                ),
              );
            }
            return false;
          }
        }else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1000),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.08,
                  bottom: MediaQuery.of(context).size.width * 0.08,
                  left: MediaQuery.of(context).size.width * 0.02,
                ),
                backgroundColor: Colors.redAccent,
                content: Text(
                  'Producto no registrado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
              ),
            );
          }
          return false;
        }
      }
    } catch (e) {
      print('Error en la búsqueda: $e');

    }
    return false;
  }
  ///funcion de scanner barcode
  void handleBarcode(String barcode) async {
    if (barcode.isEmpty) return;
    try {
      final productFound = await searchProductByBCode(barcode);
      if (mounted && productFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 700),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width * 0.08,
              bottom: MediaQuery.of(context).size.width * 0.08,
              left: MediaQuery.of(context).size.width * 0.02,
            ),
            backgroundColor: Colors.green,
            content: Text(
              'Producto agregado al carrito',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.045,
              ),
            ),
          ),
        );
      }
      //soundScaner();
    } catch (e) {
      print('Error en la búsqueda: $e');
    }
  }

  late DeviceInfo deviceInfo;


  void _onItemSelected(int option){
    setState(() {
      print(option);
    });
  }

  void onShowBlurr(bool showBlurr){
    setState(() {
      _showBlurr = showBlurr;
    });
  }

  var orientation = Orientation.portrait;
  bool isTablet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar los valores usando MediaQuery cuando el contexto está disponible
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;
  }


  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {
        deviceInfo = DeviceInfo(); // Recalcular cuando cambian las métricas
      });
    }
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityManager = KeyboardVisibilityManager();
    bool isUsingTextField = false;

    keyboardVisibilityManager.keyboardVisibilitySubscription =
        keyboardVisibilityManager.keyboardVisibilityController.onChange.listen((bool visible) {
          if (!mounted) return;

          setState(() {
            if (visible) {
              if (FocusManager.instance.primaryFocus?.context?.widget is TextField ||
                  FocusManager.instance.primaryFocus?.context?.widget is TextFormField) {
                isUsingTextField = true;
                scannerService.focusNode.unfocus();
              }
            } else {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !isUsingTextField) {
                  scannerService.focusNode.requestFocus();
                }
                isUsingTextField = false; // Resetear el flag cuando el teclado se oculta
              });
            }
          });
        });

    Future.microtask(() {
      if (!mounted) return;

      scannerService.initialize(context, handleBarcode);

      if (mounted) {
        scannerService.focusNode.addListener(() {
          if (!isUsingTextField && mounted && !keyboardVisibilityManager.keyboardVisibilityController.isVisible) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !scannerService.focusNode.hasFocus) {
                scannerService.focusNode.requestFocus();
              }
            });
          }
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          scannerService.focusNode.requestFocus();
        }
      });
    });

    WidgetsBinding.instance.addObserver(this);
    deviceInfo = DeviceInfo();
  }


/*  @override
  void initState() {
    super.initState();
    keyboardVisibilityManager = KeyboardVisibilityManager();
    bool isUsingTextField = false;
    keyboardVisibilityManager.keyboardVisibilitySubscription =
        keyboardVisibilityManager.keyboardVisibilityController.onChange.listen((bool visible) {
          if (visible) {
            if (FocusManager.instance.primaryFocus?.context?.widget is TextField ||
                FocusManager.instance.primaryFocus?.context?.widget is TextFormField) {
              isUsingTextField = true;
              scannerService.focusNode.unfocus();
            }
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !isUsingTextField) {
                scannerService.focusNode.requestFocus();
              }
            });
          }
        });
    Future.microtask(() {
      if (mounted) {
        scannerService.initialize(context, handleBarcode);
        scannerService.focusNode.addListener(() {
          if (!isUsingTextField && mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !scannerService.focusNode.hasFocus && !keyboardVisibilityManager.keyboardVisibilityController.isVisible) {
                scannerService.focusNode.requestFocus();
              }
            });
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            scannerService.focusNode.requestFocus();
          }
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
    deviceInfo = DeviceInfo();
  }*/

  void _onCancelConfirm(bool cancelConfirm) {
    setState(() {
      _cancelConfirm = cancelConfirm;
    });
  }


  onBackPressed(didPop) {
    if (!didPop) {
      setState(() {
        _selectedScreen == 3
            ? _selectedScreen = 1
            : showDialog(
          barrierDismissible: false,
          context: context,
          builder: (builder) {
            return AlertCloseDialog(
              onCancelConfirm: _onCancelConfirm,
            );
          },
        ).then((_) {
          if (_cancelConfirm == true) {
            if (_cancelConfirm) {
              Future.delayed(const Duration(milliseconds: 100), () {
                SystemNavigator.pop();
              });
            }
          }
        });
      });
      return;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.keyboardVisibilitySubscription.cancel();
    keyboardVisibilityManager.dispose();
    scannerService.dispose();
    focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onPrintServiceComunication(PrintService printService){
    setState(() {
      this.printService = printService;
    });

  }

  void onLockScreen(bool lockScreen){
    setState(() {
      this.lockScreen = lockScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
      Widget _buildBody() {
        switch (_selectedScreen) {
          case 1:
            return Categories(productsKey: productsKey, onHideBtnsBottom: onHideBtnsBottom, onShowBlur: _onShowBlur, listenerblurr: _listenerblurr, isTablet: deviceInfo.isTablet);
          case 2:
            return Cart(onHideBtnsBottom: onHideBtnsBottom, printService: printService, onShowBlurr: onShowBlurr);
          default:
            return Container();
        }
      }
      return scannerService.wrapWithKeyboardListener(
          PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                onBackPressed(didPop);
                },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.bgColor,
                endDrawer: navBar(
                    onItemSelected: _onItemSelected,
                    onShowBlur: _onShowBlur,
                    currentScreen: currentScreen,
                    onPrintServiceComunication: onPrintServiceComunication,
                    printServiceAfterInitConn: printService,
                    btChar: printService.characteristic, onLockScreen: onLockScreen, isTablet: isTablet, orientation: orientation),
                body: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top:!deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.01 : orientation == Orientation.portrait ?
                        MediaQuery.of(context).size.width * 0.01 : MediaQuery.of(context).size.height * 0.01),
                        color: AppColors.bgColor,
                        padding: EdgeInsets.only(
                            top: !deviceInfo.isTablet ? MediaQuery.of(context).size.height * 0.04 : orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.03 : orientation == Orientation.portrait ?
                                MediaQuery.of(context).size.width * 0.03 : MediaQuery.of(context).size.width * 0.03,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        _selectedScreen == 1
                                            ? 'Inventario'//'$scanedProd'
                                            : _selectedScreen == 2
                                            ? 'Venta'
                                            : '',
                                        style: !deviceInfo.isTablet ? TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: screenWidth! < 370.00
                                              ? MediaQuery.of(context).size.width * 0.078
                                              : MediaQuery.of(context).size.width * 0.082,
                                          fontWeight: FontWeight.bold,
                                        ) : TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.06: MediaQuery.of(context).size.height * 0.06,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Visibility(
                                          visible: _selectedScreen == 1 ? true : false,
                                          child: IconButton(
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const ProductForm(),
                                                ),
                                              );
                                              if (result == true) {
                                                productsKey.currentState?.refreshProducts();
                                              }
                                            },
                                            icon: Icon(
                                              CupertinoIcons.add_circled_solid,
                                              color: AppColors.primaryColor,
                                              size: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.1 : deviceInfo.orientation == Orientation.portrait ?
                                              MediaQuery.of(context).size.width * 0.065 : MediaQuery.of(context).size.height * 0.065,
                                            ),
                                          )),
                                      Visibility(
                                        visible: _selectedScreen == 2 ? true : false,
                                        child: IconButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SalesHistory(printService: printService,),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            CupertinoIcons.tickets,
                                            color: AppColors.primaryColor,
                                            size: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.1 : deviceInfo.orientation == Orientation.portrait ?
                                            MediaQuery.of(context).size.width * 0.065 : MediaQuery.of(context).size.height * 0.065,

                                        //MediaQuery.of(context).size.width * 0.1,
                                          ),
                                        ),),
                                      Builder(builder: (BuildContext context) {
                                        return IconButton(
                                          onPressed: () {
                                            Scaffold.of(context).openEndDrawer();
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/imgLog/navBar.svg',
                                            colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                                            width: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.105 : deviceInfo.orientation == Orientation.portrait ?
                                            MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.height * 0.065,
                                          ),
                                        );
                                      }),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02, left: MediaQuery.of(context).size.width * 0.02, bottom: MediaQuery.of(context).size.width * 0.025),
                                      child: Container(
                                        color: Colors.transparent,
                                        height: showScaner ? MediaQuery.of(context).size.width * 0.3 : 40,//37
                                        child: showScaner ? ScanBarCode(onShowScan: onShowScan, onScanProd: onScanProd) : TextFormField(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Seeker(onShowBlur: onShowBlurr, listenerblurr: Listenerblurr(),),
                                              ),
                                            ).then((_){
                                              focusNode.unfocus();
                                            });
                                          },
                                          controller: searchController,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.zero,
                                            hintText: 'Buscar producto...',
                                            hintStyle: TextStyle(
                                                color: AppColors.primaryColor.withOpacity(0.2)
                                            ),
                                            prefixIcon: Icon(Icons.search, color: AppColors.primaryColor.withOpacity(0.2)),
                                            suffixIcon: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    showScaner == false ? showScaner = true : showScaner = false;
                                                  });
                                                },
                                                child: const Icon(CupertinoIcons.barcode_viewfinder, color: AppColors.primaryColor)
                                            ),
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
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
                                decoration: const BoxDecoration(
                                  color: AppColors.bgColor,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15)
                                  ),
                                  border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.primaryColor,
                                        width: 2.5,
                                      )),
                                ),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.width * 0.02,
                                    right: _selectedScreen == 1 ? MediaQuery.of(context).size.width * 0.0 : MediaQuery.of(context).size.width * 0.02,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _buildBody(),
                                ),
                              ),
                            ),
                            ///botones inferiores
                            Visibility(
                              visible: !_hideBtnsBottom,
                              child: Container(
                                margin: EdgeInsets.only(bottom: screenWidth! < 391
                                    ? MediaQuery.of(context).size.width * 0.05
                                    : MediaQuery.of(context).size.width * 0.02),
                                padding: EdgeInsets.only(top: screenWidth! < 391
                                    ? MediaQuery.of(context).size.width * 0.03
                                    : MediaQuery.of(context).size.width * 0.02),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            setState(() {
                                              _selectedScreen = 1;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/imgLog/inv.svg',
                                              colorFilter: _selectedScreen == 1
                                                  ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
                                                  : ColorFilter.mode(AppColors.primaryColor.withOpacity(0.2), BlendMode.srcIn),
                                              width: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.1 : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.height * 0.06,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: !deviceInfo.isTablet ?  MediaQuery.of(context).size.width * 0.005 : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.0025 : MediaQuery.of(context).size.height * 0.0025,
                                      height: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.12 : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.07 : MediaQuery.of(context).size.height * 0.07,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        color: AppColors.primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () {
                                            setState(() {
                                              if (mounted) {
                                                _selectedScreen = 2;
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/imgLog/cart.svg',
                                              colorFilter: _selectedScreen == 2
                                                  ? const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn)
                                                  : ColorFilter.mode(AppColors.primaryColor.withOpacity(0.2), BlendMode.srcIn),
                                              width: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.1: deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.height * 0.06,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: _showBlurr,
                          child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showBlurr = false;
                                      changeBlurr();
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: AppColors.blackColor.withOpacity(0.3),
                                    child: Container(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                                      decoration: const BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Procesando la venta, espere...',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.05 : deviceInfo.orientation == Orientation.portrait ?
                                              MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                            ),),
                                          const SizedBox(height: 20,),
                                          const CircularProgressIndicator(
                                            color: AppColors.primaryColor,
                                          )
                                        ],
                                      )
                                    ),
                                  ))))])),
            Visibility(
                visible: lockScreen,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeAlign: 15,
                      strokeWidth: 4.5,
                    ),
                  ),
                ))
          ],
        )));
  }
}