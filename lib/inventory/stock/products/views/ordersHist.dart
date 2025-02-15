import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../deviceThresholds.dart';
import '../../../../helpers/themes/colors.dart';
import '../utils/sliverlist/cardOrder.dart';

class OrdersHist extends StatefulWidget {
  const OrdersHist({super.key});

  @override
  State<OrdersHist> createState() => _OrdersHistState();
}

class _OrdersHistState extends State<OrdersHist> {

  List<Map<String, dynamic>> orders = [
    {'id': 1, 'prov': 'Coca Cola', 'date': '14/02/2025', 'time': '00:00', 'total': 5000, 'prod': [{'id': 1, 'code': '1234567890', 'name': 'Coca Cola 600 ml', 'cant': 10, 'price': 19.5}, {'id': 2, 'code': '2234567890', 'name': 'Cristal Fresa 600 ml', 'cant': 20, 'price': 19.0}]},
    {'id': 2, 'prov': 'Marinela', 'date': '14/02/2025', 'time': '00:20', 'total': 7000, 'prod': [{'id': 4, 'code': '1234567890', 'name': 'Coca Cola 600 ml', 'cant': 10, 'price': 19.5}, {'id': 3, 'code': '2234567890', 'name': 'Cristal Fresa 600 ml', 'cant': 20, 'price': 19.5}]},
    {'id': 3, 'prov': 'Sabritas', 'date': '14/02/2025', 'time': '00:50', 'total': 3000, 'prod': [{'id': 5, 'code': '1234567890', 'name': 'Coca Cola 600 ml', 'cant': 10, 'price': 19.0}, {'id': 6, 'code': '2234567890', 'name': 'Cristal Fresa 600 ml', 'cant': 20, 'price': 19.5}]},
  ];

  Orientation orientation = Orientation.portrait;
  bool isTablet = false;
  bool isLoading = false;
  List<ExpansionTileController>? tileController = [];
  int helperExpansion = 0;

  bool isTabletDevice(double width, double height, Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return height > DeviceThresholds.minTabletHeightPortrait &&
          width > DeviceThresholds.minTabletWidth;
    } else {
      return height > DeviceThresholds.minTabletHeightLandscape &&
          width > DeviceThresholds.minTabletWidthLandscape;
    }
  }

  void onOpenTile (index, isOpen) {
    if (helperExpansion != index) {
      tileController?[helperExpansion].collapse();
    }
    tileController?[index].expand();
    helperExpansion = index;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var order in orders) {
      tileController?.add(ExpansionTileController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors3.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors3.whiteColor,
            leadingWidth: MediaQuery.of(context).size.width,
            leading: Row(
              children: [
                IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                        CupertinoIcons.chevron_back, size: MediaQuery.of(context).size.width * 0.08,
                        color: AppColors3.primaryColor
                    )
                ),
                Text(
                    'Historial de pedidos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors3.primaryColor,
                      fontSize: MediaQuery.of(context).size.width * 0.065,
                    )
                ),
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.1,
                    right: MediaQuery.of(context).size.width * 0.01,
                    left: MediaQuery.of(context).size.width * 0.01
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return Container(
                      color: AppColors3.bgColor,
                      child: !isLoading ? (
                        orders.isNotEmpty ? Container(
                          margin: orientation == Orientation.portrait ?
                          EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03,
                              right: MediaQuery.of(context).size.width * 0.03,
                              bottom: MediaQuery.of(context).size.width * 0.03) :
                          EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.03,
                              right: MediaQuery.of(context).size.height * 0.03,
                              bottom: MediaQuery.of(context).size.height * 0.03) ,
                          decoration: BoxDecoration(
                            color: AppColors3.bgColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors3.blackColor.withOpacity(0.1),
                                offset: const Offset(4, 4),
                                blurRadius: 2,
                                spreadRadius: 0.1,
                              )
                            ],
                          ),
                          child: GestureDetector(
                            onLongPress: () {

                            },
                            child: CardOrder(orders: orders, index: index, orientation: orientation, isTablet: isTablet, expansionTileController: tileController![index], onOpenTile: onOpenTile),
                          ),
                        ) : Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'No hay pedidos correspondientes a la fecha seleccionada',
                            style: TextStyle(
                                fontSize: !isTablet ? MediaQuery.of(context).size.width * 0.045 : orientation == Orientation.portrait ?
                                MediaQuery.of(context).size.width * 0.045 : MediaQuery.of(context).size.height * 0.045,
                                color: AppColors.primaryColor
                            ),
                          ),
                        )
                      ) : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  },
                    childCount: orders.length
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
