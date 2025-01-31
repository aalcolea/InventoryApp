import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../themes/colors.dart';

Future<Map<String, dynamic>?> showConfirmSellDialog(BuildContext context) async {
  bool isCardPayment = false;
  bool shouldPrint = false;
  return await showDialog<Map<String, dynamic>>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.whiteColor,
                ),
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02, horizontal: MediaQuery.of(context).size.width * 0.05),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          'Confirmar venta',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.08,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * 0.02),
                        child: Text(
                          '¿Seguro que quieres completar esta venta?',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            bottom: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            ),
                            top: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            ),
                            left: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            ),
                            right: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.07),
                              title: Text(
                                'Pago con tarjeta',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              value: isCardPayment,
                              onChanged: (bool? value) {
                                setState(() {
                                  isCardPayment = value ?? false;
                                });
                              },
                            ),
                            CheckboxListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery.of(context).size.width * 0.07),
                              title: Text(
                                'Imprimir ticket',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              value: shouldPrint,
                              onChanged: (bool? value) {
                                setState(() {
                                  shouldPrint = value ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.05,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop({
                                  'isCardPayment': isCardPayment,
                                  'shouldPrint': shouldPrint,
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.05,
                                    vertical: MediaQuery.of(context).size.height * 0.01
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Confirmar',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ),
            ),
          );
        },
      );
    },
  );
}