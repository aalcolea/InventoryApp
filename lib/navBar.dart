import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'globalVar.dart';
import 'helpers/services/auth_service.dart';
import 'helpers/themes/colors.dart';
import 'inventory/listenerPrintService.dart';
import 'inventory/print/printConnections.dart';
import 'inventory/stock/addProd/ views/recieveProduct.dart';

class navBar extends StatefulWidget {
  final void Function(bool) onShowBlur;
  final Function(PrintService)? onPrintServiceComunication;
  final PrintService? printServiceAfterInitConn;
  final BluetoothCharacteristic? btChar;
  final Function(int) onItemSelected;
  final void Function(bool) onLockScreen;
  final String currentScreen;
  final bool isTablet;
  final Orientation orientation;

  const navBar({super.key, required this.onItemSelected, required this.onShowBlur, required this.currentScreen,
    this.onPrintServiceComunication, this.printServiceAfterInitConn, this.btChar, required this.onLockScreen, required this.isTablet, required this.orientation});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  PrintService printService = PrintService();
  ListenerPrintService listenerPrintService = ListenerPrintService();
  bool? isConecct = false;



  void closeMenu(BuildContext context){
    Navigator.of(context).pop();
  }

  var orientation = Orientation.portrait;
  bool isTablet = false;
  double? screenWidth;
  double? screenHeight;

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
  void initState() {
    orientation = widget.orientation;
    if(widget.btChar != null){
      setState(() {
        printService.selectedDevice = widget.printServiceAfterInitConn?.selectedDevice;
        printService.isConnect = true;
        isConecct = true;
      });
    }else {
      setState(() {
        isConecct = false;
      });
    }
    printService.listenerPrintService.registrarObservador((newValue, newIsConnect) {
      setState(() {
        switch (newValue) {
          case 0:
            setState(() {//null
              isConecct = newIsConnect;
              widget.onLockScreen(true);
            });
          case 1:
            setState(() {//conectado
              isConecct = newIsConnect;
              widget.onPrintServiceComunication!(printService);
              widget.onLockScreen(false);

            });
            break;
          case 2://conect == false
            setState(() {
              print('disconect');
              isConecct = newIsConnect;
              widget.onPrintServiceComunication!(printService);
            });
            break;
          case 3://no encontro disp
            setState(() {
              print('not found navBar');
              isConecct = false;
              widget.onLockScreen(false);
            });
            break;
        }
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrintService>(
        create: (_) => printService,
        child: Consumer<PrintService>(
        builder: (context, printService, child){
          return  Drawer(
            width: !widget.isTablet ? MediaQuery.of(context).size.width * 0.725 : orientation == Orientation.portrait ?
            MediaQuery.of(context).size.width * 0.55 : MediaQuery.of(context).size.height * 0.55,
            backgroundColor: AppColors3.whiteColor,
            child: Stack(
              children: [
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    padding: !widget.isTablet ? EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.17) : orientation == Orientation.portrait ?
                    EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.17) :
                    EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
                    child: Column(
                        children: [
                          Padding(
                            padding: !widget.isTablet ? EdgeInsets.only(bottom: 30, left: 20) : orientation == Orientation.portrait ? EdgeInsets.only(bottom: 30, left: 20) : EdgeInsets.only(bottom: 30, left: 20),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: !widget.isTablet ? MediaQuery.of(context).size.width * 0.05 : orientation == Orientation.portrait ?
                                    MediaQuery.of(context).size.width * 0.045 : MediaQuery.of(context).size.height * 0.045,
                                    backgroundColor: AppColors3.primaryColor,
                                    child: Icon(Icons.person, color: Colors.white, size: !widget.isTablet ? MediaQuery.of(context).size.width * 0.08 : MediaQuery.of(context).size.height * 0.05)
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      child:
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(SessionManager.instance.Nombre == 'Dulce' ? 'Admin' : SessionManager.instance.Nombre,
                                              style: !widget.isTablet ? TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.05,
                                                  color: AppColors3.primaryColor) :
                                              TextStyle(
                                                  fontWeight: FontWeight.bold, fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 :  MediaQuery.of(context).size.height * 0.04,
                                                  color: AppColors3.primaryColor)),
                                          Text('MiniSuper San Juan Diego', style: TextStyle(color: AppColors3.primaryColor.withOpacity(0.8)),)
                                        ],
                                      )
                                  )
                                ]
                            ),
                          ),
                          Divider(
                            thickness: 1.5,
                            color: AppColors3.primaryColor.withOpacity(0.3),
                            height: 5 ,
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RecieveProduct()),
                                );
                              },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.05,
                                    top: MediaQuery.of(context).size.width * 0.025,
                                    bottom: MediaQuery.of(context).size.width * 0.025,
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Alta de productos', style: !widget.isTablet ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context).size.width * 0.05,
                                          color: AppColors3.primaryColor
                                      ) : TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                          color: AppColors3.primaryColor
                                      ),),
                                    ],
                                  ),
                                ),
                                Divider(
                                  thickness: 1.5,
                                  indent: MediaQuery.of(context).size.width * 0.04,
                                  endIndent: MediaQuery.of(context).size.width * 0.04,
                                  color: AppColors3.primaryColor.withOpacity(0.3),
                                  height: 5 ,
                                ),
                              ],
                            )
                          ),

                          Visibility(
                            visible: widget.currentScreen == 'inventario' ? true : false,
                            child: InkWell(
                                splashColor: AppColors3.primaryColor.withOpacity(0.1),
                                onTap: isConecct == false ? () {
                                  setState(() {
                                    Platform.isIOS ? printService.scanForDevices(context) :
                                    printService.connectToBluetoothDevice(context);
                                  });
                                } : (){
                                  setState(() {
                                    printService.disconnect(context);
                                    isConecct = false;
                                  });
                                },
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                      padding: const EdgeInsets.only(left: 20, top: 10),
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerLeft,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * 0.0,
                                                  right: MediaQuery.of(context).size.width * 0.04,
                                                ),
                                                child: Icon(
                                                  isConecct == null ? Icons.print_disabled_outlined : !isConecct! ?  Icons.print_disabled_outlined : Icons.print_outlined,
                                                  size: !widget.isTablet ? MediaQuery.of(context).size.width * 0.08 : orientation == Orientation.portrait ?
                                                  MediaQuery.of(context).size.width * 0.07 : MediaQuery.of(context).size.height * 0.07,
                                                  color: AppColors3.primaryColor,),),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Impresora',
                                                      style: !widget.isTablet ? TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: MediaQuery.of(context).size.width * 0.05,
                                                          color: AppColors3.primaryColor
                                                      ) : TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                                          color: AppColors3.primaryColor
                                                      ),
                                                    ),Text(
                                                      isConecct == null ? 'Conectando...' : isConecct! ? 'Conectada' : 'Desconectada',
                                                      style: !widget.isTablet ? TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: MediaQuery.of(context).size.width * 0.04,
                                                          color: AppColors3.primaryColor.withOpacity(0.4)
                                                      ) : TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                                                          color: AppColors3.primaryColor.withOpacity(0.4)
                                                      ),
                                                      /*style: TextStyle(
                                                          fontSize: MediaQuery.of(context).size.width*0.04,
                                                          color: AppColors3.primaryColor.withOpacity(0.4)
                                                      ),*/
                                                    ),
                                                  ],
                                                ),),
                                              Visibility(
                                                visible: isConecct == null ? true : false,
                                                child: Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.12),
                                                    child: CircularProgressIndicator(
                                                      color: AppColors3.primaryColor.withOpacity(0.8),
                                                    )),),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.width * 0.02,),
                                          Divider(
                                            thickness: 1.5,
                                            indent: MediaQuery.of(context).size.width * 0.0,
                                            endIndent: MediaQuery.of(context).size.width * 0.04,
                                            color: AppColors3.primaryColor.withOpacity(0.3),
                                            height: 5 ,
                                          ),
                                        ],
                                      )
                                  ),
                                )
                            ),),
                          ///Icono escoger impresora
                          /*IconButton(onPressed: (){
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => testPrint(),
                              ),
                            );

                          }, icon: Icon(Icons.ac_unit)),*/
                          Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.03),
                                  alignment: Alignment.bottomCenter,
                                  child:
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              PinEntryScreenState().logout(context);
                                            },
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.exit_to_app, color: AppColors3.primaryColor,
                                                  size: !widget.isTablet ? MediaQuery.of(context).size.width * 0.08 : orientation == Orientation.portrait ?  MediaQuery.of(context).size.width * 0.055 :
                                                  MediaQuery.of(context).size.height * 0.055,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Cerrar sesion', style: !widget.isTablet ? TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: MediaQuery.of(context).size.width * 0.05,
                                                      color: AppColors3.primaryColor
                                                  ) : TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.height * 0.05,
                                                      color: AppColors3.primaryColor
                                                  ),)
                                                ]))])))])),

              ],
            )
          );
        })
    );
  }
}
