import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../helpers/utils/showToast.dart';
import '../../../../../helpers/utils/toastWidget.dart';
import '../../services/stockService.dart';
import '../../../../themes/colors.dart';

class ModifyProductStockDialog extends StatefulWidget {
  final String nombreProd;
  final int cantProd;
  final int idProd;
  final Future<void> Function(int) onModify;

  const ModifyProductStockDialog({
    super.key,
    required this.nombreProd,
    required this.cantProd,
    required this.onModify,
    required this.idProd,
  });

  @override
  _ModifyProductStockDialogState createState() =>
      _ModifyProductStockDialogState();

}

class _ModifyProductStockDialogState extends State<ModifyProductStockDialog> {
  late int _currentStock;
  late TextEditingController _stockController;
  final stockService = StockService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStock = widget.cantProd;
    _stockController = TextEditingController(text: '$_currentStock');
  }

  void _incrementStock() {
    setState(() {
      _currentStock++;
      _stockController.text = '$_currentStock';
    });
  }

  void _decrementStock() {
    setState(() {
      if (_currentStock > 0) {
        _currentStock--;
        _stockController.text = '$_currentStock';
      }
    });
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: IntrinsicHeight(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.015,
              left: MediaQuery.of(context).size.height * 0.02,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.whiteColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01),
                          child: Text(
                            'Modificar stock',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.07,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Visibility(
                              visible: _currentStock != widget.cantProd,
                              child: IconButton(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.03,
                                ),
                                onPressed: () {
                                  widget.onModify(_currentStock);
                                  Navigator.of(context).pop(true);
                                },
                                icon: const Icon(
                                  CupertinoIcons.check_mark,
                                  color: AppColors.primaryColor,
                                )
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                color: AppColors.primaryColor,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Text(
                      widget.nombreProd,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onPressed: _decrementStock,
                        child: Icon(
                          CupertinoIcons.minus,
                          color: AppColors.whiteColor,
                          size: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        child: TextField(
                          controller: _stockController,
                          style: const TextStyle(fontSize: 30),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              text.isNotEmpty ? _currentStock = int.parse(text) : _currentStock = 0;
                            });
                          },
                        ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(40, 40),
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.02,
                              vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onPressed: _incrementStock,
                        child: Icon(
                          CupertinoIcons.add,
                          color: AppColors.whiteColor,
                          size: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}