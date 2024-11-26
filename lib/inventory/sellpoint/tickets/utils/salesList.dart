import 'dart:io';

import 'package:inventory_app/inventory/print/printSalesService.dart';
import 'package:inventory_app/inventory/print/printService.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/sales/listenerQuery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../print/printConnections.dart';
import '../../../print/salesPDF.dart';
import '../../../print/testPDF.dart';
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

  const SalesList({super.key, required this.onShowBlur, required this.listenerOnDateChanged, required this.dateController, required this.onDateChanged, required this.printService, required this.listenerQuery});

  @override
  State<SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {

  bool isLoading = false;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> productsFilterd = [];
  late String formattedDate;
  late SalesPrintService salesPrintService;
  String? _initDate;
  String? _finalDate;
  String? query;

  void filterSales(String? query){
    if(mounted){
      setState(() {
        query?.toLowerCase();
        if(query!.isEmpty){
          productsFilterd = products;
          print('asd $productsFilterd');
        } else {
          productsFilterd = products.where((prod){
            final matchesProducts = prod['nombre'].toString().toLowerCase().contains(query);
            print('hola $products');
            return matchesProducts;
          }).toList();}});}
  }

  @override
  void initState() {
    super.initState();
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
  }

  Future<void> fetchSales(String? initData, String? finalData) async{
    setState(() {
      isLoading = true;
      widget.onDateChanged(initData!);
    });
    try{
      final salesService = SalesServices();
      //await salesService.fetchSales();
      final products2 = await salesService.getSalesByProduct(initData, finalData);
      setState(() {
        products = products2;
        productsFilterd = products;
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgColor,
      child: Column(
        children: [
          Expanded(
            child: !isLoading
                ? ( products.isNotEmpty ? ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
              itemCount: productsFilterd.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.0075,
                            horizontal: MediaQuery.of(context).size.width * 0.0247),
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
                                      "Cant.:",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '${productsFilterd[index]['cantidad']} pzs',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Precio unitario: ",
                                      style: TextStyle(
                                          color: AppColors.primaryColor.withOpacity(0.5),
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${productsFilterd [index]['precio']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
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
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '\$${productsFilterd[index]['total'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
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
                                          fontSize: MediaQuery.of(context).size.width * 0.035),
                                    ),
                                    Text(
                                      '${productsFilterd[index]['fecha_venta']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
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
                        thickness: MediaQuery.of(context).size.width * 0.0055,
                      ),
                    ],
                  ),
                );
              },
            ) : const Center(
              child: Text(
                'No hay tickets correspondientes a la fecha seleccionada',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            )) : const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Container(
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
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.12,
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
                          Platform.isAndroid ? await salesPrintService.connectAndPrintAndroide(productsFilterd, 'assets/imgLog/test2.jpeg', products[0]['fecha_venta']) :
                      await salesPrintService.connectAndPrintIOS(productsFilterd, 'assets/imgLog/test2.jpeg', products[0]['fecha_venta']);
                      } catch(e){
                      print("Error al intentar imprimir: $e");
                      showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                      }}} : null,
                    icon: Icon(
                      CupertinoIcons.printer_fill,
                      color: productsFilterd.isNotEmpty ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                      size: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.005,
                  height: MediaQuery.of(context).size.width * 0.15,
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
                          builder: (context) => SalesPDF(sales: productsFilterd,),
                        ),
                      );
                      print('filtrados $productsFilterd');
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_down_doc_fill,
                      color:  productsFilterd.isNotEmpty ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.3),
                      size: MediaQuery.of(context).size.height * 0.05,
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
              fontSize: MediaQuery.of(context).size.width * 0.05));
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
              fontSize: MediaQuery.of(context).size.width * 0.05));
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
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  )),
              TextSpan(
                  text: matchText,
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      height: 2,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
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
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ))]));
  }
}