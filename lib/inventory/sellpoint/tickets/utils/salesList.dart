import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/establishmentInfo.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/sales/listenerQuery.dart';
import '../../../../deviceThresholds.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../print/printConnections.dart';
import '../../../print/printSalesService.dart';
import '../../../print/salesPDF.dart';
import '../../../themes/colors.dart';
import '../services/salesServices.dart';
import 'listenerOnDateChanged.dart';

class SalesList extends StatefulWidget {
  final void Function(int) onShowBlur;
  final ListenerOnDateChanged listenerOnDateChanged;
  final String dateController;
  final void Function(String) onDateChanged;
  final PrintService printService;
  final ListenerQuery listenerQuery;
  final bool isTablet;

  const SalesList({super.key, required this.onShowBlur, required this.listenerOnDateChanged, required this.dateController, required this.onDateChanged, required this.printService, required this.listenerQuery, required this.isTablet});

  @override
  State<SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> with WidgetsBindingObserver{

  bool isLoading = false;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> productsFilterd = [];
  late String formattedDate;
  late SalesPrintService salesPrintService;
  String? _initDate;
  String? _finalDate;
  String? query;
  double cantTotalEfectivo = 0;
  double cantTotalTarjeta = 0;

  void filterSales(String? query) {
    if (mounted) {
      setState(() {
        query = query?.toLowerCase() ?? '';
        if (query!.isEmpty) {
          productsFilterd = products;
        } else {
          productsFilterd = products.where((prod) {
            final matchesName = prod['nombre'].toString().toLowerCase().contains(query!);
            final matchingCategory = cat.firstWhere(
                  (category) => category['category'].toString().toLowerCase().contains(query!),
              orElse: () => {'id': null},
            );
            final matchesCategory = matchingCategory['id'] != null &&
                prod['category_id'].toString() == matchingCategory['id'].toString();
            return matchesName || matchesCategory;
          }).toList();
        }
      });
    }
  }

  double? screenWidth;
  double? screenHeight;

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

  @override
  void initState() {
    super.initState();
    isTablet = widget.isTablet;
    fetchSales(widget.dateController, widget.dateController);
    widget.listenerOnDateChanged.registrarObservador((callback, initData, finalData) async {
      if (callback) {
        _finalDate = initData;
        _initDate = initData;
        await fetchSales(initData, finalData);
      }
    });
    widget.listenerQuery.registrarObservador((query)  {
          this.query = query;
          filterSales(this.query);
          print(this.query);
    });
    WidgetsBinding.instance.addObserver(this);
    _initializeDeviceType();
    loadCategories();

  }

  @override
  void didChangeMetrics() {
    if(mounted){
      setState(() {
        _initializeDeviceType();
      });
    }
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


  Future<void> fetchSales(String? initData, String? finalData) async{
    setState(() {
      isLoading = true;
      widget.onDateChanged(initData!);
    });
    try{
      final salesService = SalesServices();
      final tickets2 = await salesService.fetchSales(initData, finalData);//esto es para obtener el $ total de efectivo y tarjeta
      final products2 = await salesService.getSalesByProduct(initData, finalData);
      products = products2;
      productsFilterd = products;
      for (var ticket in tickets2) {
        if (ticket["tipoVenta"] == "Efectivo") {
          ticket['total'] != null ? cantTotalEfectivo += double.parse(ticket['total']) : null;
        } else if(ticket["tipoVenta"] == "Tarjeta"){
          ticket['total'] != null ? cantTotalTarjeta += double.parse(ticket['total']) : null;
        }
      }
      setState(() {
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      isLoading = false;
    }
  }

  int limit = 6;
  int offset = 0;
  List<Map<String, dynamic>> cat = [];
  Future<void> loadCategories() async{
    try{
      setState(() {
        cat.clear();
        offset = 0;
      });
      List<Map<String, dynamic>> fetchedItems = await SalesServices().fetchCategories(limit: limit, offset: offset);
      setState(() {
        cat = fetchedItems;
        offset += limit;
        isLoading = false;
      });
    }catch(e){
      print('Error al cargar los items $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        children: [
          Expanded(///mejorar este ternario
            child: !isLoading ? ( products.isNotEmpty ? ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.02 : MediaQuery.of(context).size.height * 0.02),
              itemCount: productsFilterd.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.0075 : MediaQuery.of(context).size.height * 0.0075,
                            horizontal: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.0247 : MediaQuery.of(context).size.height * 0.0247),
                        title: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                highlightTextTitle(productsFilterd[index]['nombre'], query ?? ''),
                                Row(
                                  children: [
                                    Text(
                                      "Cant.: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                        MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                                    ),
                                    Text(
                                      '${productsFilterd[index]['cantidad']} pzs',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                        MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Precio unitario: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                        MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                                    ),
                                    Text(
                                      '\$${productsFilterd [index]['precio']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                          fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Total: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                        MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                                    ),
                                    Text(
                                      '\$${productsFilterd[index]['total'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                          fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Fecha de venta: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                        fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                        MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                                    ),
                                    Text(
                                      '${productsFilterd[index]['fecha_venta']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                          fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.035 : orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: AppColors.primaryColor,
                        thickness: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.0055 : MediaQuery.of(context).size.height * 0.0055,
                      ),
                    ],
                  ),
                );
              },
            ) : const Center(
              child: Text(
                textAlign: TextAlign.center,
                 'No hay ventas correspondientes a la fecha seleccionada',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            )) : const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                vertical: !isTablet ? MediaQuery.of(context).size.width * 0.02 : orientation == Orientation.portrait ?
            MediaQuery.of(context).size.width * 0.012 : MediaQuery.of(context).size.height * 0.012),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              border: const Border(top: BorderSide(color: AppColors.primaryColor, width: 2)),
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.15),
                  offset: const Offset(4, -5),
                  blurRadius: 5,
                  spreadRadius: 0.1,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: productsFilterd.isNotEmpty ? () async {
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
                      if (canPrint) {
                        salesPrintService = SalesPrintService(widget.printService.characteristic!);
                        try{
                          Platform.isAndroid ? await salesPrintService.connectAndPrintAndroide(productsFilterd, Establishmentinfo.logoRootAsset,
                              products[0]['fecha_venta'], Establishmentinfo.logo) :
                      await salesPrintService.connectAndPrintIOS(productsFilterd, Establishmentinfo.logoRootAsset, products[0]['fecha_venta'], Establishmentinfo.logo);
                      } catch(e){
                      print("Error al intentar imprimir: $e");
                      showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                      }}} : null,
                    icon: Icon(
                      CupertinoIcons.printer_fill,
                      color: productsFilterd.isNotEmpty ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                      size: !isTablet ? MediaQuery.of(context).size.height * 0.05 : orientation == Orientation.portrait ?
                      MediaQuery.of(context).size.width * 0.062 : MediaQuery.of(context).size.height * 0.062,
                    ),
                  ),
                ),
                Container(
                  width: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.005 : MediaQuery.of(context).size.height * 0.005,
                  height: !isTablet ? MediaQuery.of(context).size.height * 0.1 : orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.1 : MediaQuery.of(context).size.height * 0.1, /*orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.15 : MediaQuery.of(context).size.height * 0.15,*/
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => SalesPDF(
                            sales: productsFilterd, nameEstableciment: Establishmentinfo.name, direccion: Establishmentinfo.street,
                              email:  Establishmentinfo.email, totalEfectivo: cantTotalEfectivo, totalTarjeta: cantTotalTarjeta),
                        ),
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_down_doc_fill,
                      color:  productsFilterd.isNotEmpty ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                      size: !isTablet ? MediaQuery.of(context).size.height * 0.05 : orientation == Orientation.portrait ?
                      MediaQuery.of(context).size.width * 0.065 : MediaQuery.of(context).size.height * 0.065,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }

  Widget highlightTextTitle(String text, String? query) {
    if (query!.isEmpty) {
      return Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(
            color: AppColors.primaryColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              height: 2,
            fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
            MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,));
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    final startIndex = lowerCaseText.indexOf(lowerCaseQuery);
    if (startIndex == -1) {
      return Text(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text,
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              height: 2,
            fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
            MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,));
    }

    final beforeMatch = text.substring(0, startIndex);
    final matchText = text.substring(startIndex, startIndex + query.length);
    final afterMatch = text.substring(startIndex + query.length);

    return Text.rich(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        TextSpan(
            children: [
              TextSpan(
                  text: beforeMatch,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
                    MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                  )),
              TextSpan(
                  text: matchText,
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      height: 2,
                      fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
                      MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                      fontStyle: FontStyle.normal,
                      decoration: TextDecoration.underline
                  )),
              TextSpan(
                  text: afterMatch,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    height: 2,
                    fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
                    MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                  ))]));
  }
}