import 'package:flutter/material.dart';

import '../../../../../deviceThresholds.dart';
import '../../../../../helpers/themes/colors.dart';

class CardOrder extends StatefulWidget {

  final List<Map<String, dynamic>> orders;
  final int index;
  final Orientation orientation;
  final bool isTablet;
  final ExpansionTileController expansionTileController;
  final Function(int, bool) onOpenTile;
  const CardOrder({super.key, required this.orders, required this.index, required this.orientation, required this.isTablet, required this.expansionTileController, required this.onOpenTile});

  @override
  State<CardOrder> createState() => _CardOrderState();
}

class _CardOrderState extends State<CardOrder> {

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (expand) {
        if (expand) {
          widget.onOpenTile(widget.index, true);
        } else {}
      },
      controller: widget.expansionTileController,
      iconColor: AppColors3.bgColor,
      collapsedIconColor: AppColors3.primaryColor,
      backgroundColor: AppColors3.primaryColor,
      collapsedBackgroundColor: Colors.transparent,
      textColor: AppColors3.bgColor,
      collapsedTextColor: AppColors3.primaryColor,
      tilePadding: widget.orientation == Orientation.portrait ?
      EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.04,
          right: MediaQuery.of(context).size.width * 0.02,
          top: MediaQuery.of(context).size.width * 0.01,
          bottom: MediaQuery.of(context).size.width * 0.015
      ) : EdgeInsets.only(
          left: MediaQuery.of(context).size.height * 0.04,
          right: MediaQuery.of(context).size.height * 0.02,
          top: MediaQuery.of(context).size.height * 0.01,
          bottom: MediaQuery.of(context).size.height * 0.015
      ),
      initiallyExpanded: false,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
              color: AppColors3.primaryColor,
              width: 2
          )
      ),
      title: Text(
        'Pedido #${widget.orders[widget.index]['id']}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.05 : widget.orientation == Orientation.portrait ?
          MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Fecha: ',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
              Text(
                '${widget.orders[widget.index]['date']}',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Proveedor: ',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
              Text(
                '${widget.orders[widget.index]['prov']}',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Total: ',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
              Text(
                '\$${widget.orders[widget.index]['total']}',
                style: TextStyle(
                  fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.04),
          decoration: const BoxDecoration(
              color: AppColors3.bgColor,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
              border: Border(
                  top: BorderSide(color: AppColors3.primaryColor, width: 2)
              )
          ),
          child: Column(
            children: widget.orders[widget.index]['prod'].map<Widget>((product) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: !widget.isTablet ? MediaQuery.of(context).size.width * 0.06 : widget.orientation == Orientation.portrait ?
                    MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.height * 0.06),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product['name']}',
                      style: TextStyle(
                        color: AppColors3.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.04 : widget.orientation == Orientation.portrait ?
                        MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Cant.: ",
                          style: TextStyle(
                            color: AppColors3.primaryColor,
                            fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                        ),
                        Text(
                          '${product['cant']} pzs',
                          style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
                              MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Precio unitario: ",
                          style: TextStyle(
                            color: AppColors3.primaryColor,
                            fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                        ),
                        Text(
                          '\$${product['price']} MXN',
                          style: TextStyle(
                            color: AppColors3.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
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
                            color: AppColors3.primaryColor,
                            fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,),
                        ),
                        Text(
                          '\$${product['cant'] * product['price']} MXN',
                          style: TextStyle(
                            color: AppColors3.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: !widget.isTablet ? MediaQuery.of(context).size.width * 0.035 : widget.orientation == Orientation.portrait ?
                            MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        )
      ],
    );
  }
}
