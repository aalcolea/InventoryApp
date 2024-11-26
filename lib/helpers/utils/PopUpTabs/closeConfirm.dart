import 'dart:ui';
import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class AlertCloseDialog extends StatefulWidget {
  final void Function(bool) onCancelConfirm;

  const AlertCloseDialog({super.key, required this.onCancelConfirm});

  @override
  State<AlertCloseDialog> createState() => _AlertCloseDialogState();
}

class _AlertCloseDialogState extends State<AlertCloseDialog> {
  bool cancelConfirm = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.width * 0.075,
              left: MediaQuery.of(context).size.width * 0.02,
              right: MediaQuery.of(context).size.width * 0.02,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors2.primaryColor, width: 0.5),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(blurRadius: 3.5, offset: Offset(0, 0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.012,
                      ),
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.052,
                        backgroundImage: AssetImage("assets/imgLog/logoBeauteWhite.png"),
                      ),
                    ),

                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.01,
                            ),
                            child: Text(
                              'Confirmar',
                              style: TextStyle(
                                fontSize:
                                MediaQuery.of(context).size.width * 0.0525,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '¿Deseas cerrar la app?',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.0425,
                            ),
                          ),
                        ],
                      ),/*Text(
                        '¿Deseas cerrar la aaaaaapp?',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.065,
                          color: AppColors2.primaryColor,
                        ),
                      ),*/
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.01),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors2.primaryColor,
                            width: 0.75,
                          ),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            cancelConfirm = true;
                          });
                          widget.onCancelConfirm(cancelConfirm);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Salir',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors2.primaryColor,
                          width: 0.75,
                        ),
                        padding: const EdgeInsets.all(4),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0),),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
