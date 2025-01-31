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
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.whiteColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        'Confirmar venta',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.07,
                          vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Text(
                        '¿Seguro que quieres completar esta venta?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.07),
                      title: Text(
                        'Pago con tarjeta',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: AppColors.blackColor,
                        ),
                      ),
                      value: isCardPayment,
                      onChanged: (bool? value) {
                        setState(() {
                          isCardPayment = value ?? false;
                        });
                      },
                    ),CheckboxListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.07),
                      title: Text(
                        'Imprimir ticket',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(null);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.03),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.redDelete,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                color: AppColors.redDelete,
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
                                horizontal: MediaQuery.of(context).size.width * 0.03),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: 2.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}