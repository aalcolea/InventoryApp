import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_app/regEx.dart';

import '../../../themes/colors.dart';

class CardProductToAdd extends StatefulWidget {
  final List<Map<String, dynamic>> productsToAdd;
  final int index;
  final Function(int) onIndexToDelete;
  final Function(int, int) onCalculateTotal;

  const CardProductToAdd({super.key, required this.productsToAdd, required this.index, required this.onIndexToDelete, required this.onCalculateTotal});

  @override
  State<CardProductToAdd> createState() => _CardProductToAddState();
}

class _CardProductToAddState extends State<CardProductToAdd> {

  bool showAllName = false;


  @override
  Widget build(BuildContext context) {
    TextEditingController stockController = widget.productsToAdd[widget.index]['controller'];
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.035),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    showAllName == true ? showAllName = false : showAllName = true;
                  });
                },
                child: Text(
                  textAlign: TextAlign.left,
                  maxLines: !showAllName ? 2 : null,
                  overflow: !showAllName ? TextOverflow.ellipsis : null,
                  widget.productsToAdd[widget.index]['nombre'], style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),),
              ),
              Text(widget.productsToAdd[widget.index]['precioRet'], style: TextStyle(
                color: AppColors.primaryColor.withOpacity(0.5),
                fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),),
            ],
          ),),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
                children: [
                  const TextSpan(
                    text: '\$', // Símbolo de peso al inicio
                  ),
                  TextSpan(
                    text: (double.parse(widget.productsToAdd[widget.index]['precioRet']) * widget.productsToAdd[widget.index]['cantToAdd']).toStringAsFixed(2),
                  ),
                  TextSpan(
                    text: '\nMXN', // MXN al final
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),

          Flexible(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: stockController.text == '1' ? (){
                  widget.onCalculateTotal(widget.index, int.parse(stockController.text));
                  widget.onIndexToDelete(widget.index);
                } : (){
                  setState(()=> stockController.text = (int.parse(stockController.text) - 1).toString());
                  widget.onCalculateTotal(widget.index, int.parse(stockController.text));
                }, icon: stockController.text == '1' ? const Icon(
                    color: AppColors.whiteColor,
                    Icons.delete_forever) : const Icon(
                    color: AppColors.whiteColor,
                    CupertinoIcons.minus)),
                Flexible(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: stockController,
                    inputFormatters: [
                      RegEx(type: InputFormatterType.numeric),
                  ],
                    style: TextStyle(
                        color: AppColors.whiteColor),
                  ),
                ),
                IconButton(onPressed: (){
                  setState(() {
                    stockController.text = (int.parse(stockController.text) + 1).toString();
                    widget.onCalculateTotal(widget.index, int.parse(stockController.text));
                  });
                }, icon: const Icon(Icons.add,
                  color: AppColors.whiteColor,)),
              ],),))],
      ),
    );
  }
}
