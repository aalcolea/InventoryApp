import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../helpers/themes/colors.dart';
import '../../../../helpers/utils/showToast.dart';
import '../../../../helpers/utils/toastWidget.dart';
import '../../../print/printConnections.dart';
import '../../../print/printService.dart';
import '../../../print/testPDF.dart';
import '../../../themes/colors.dart';

class TicketOptions extends StatefulWidget {
  final double heigthCard;
  final List<dynamic> ticketInfo;
  final VoidCallback onClose;
  final Function(double) columnHeight;
  final void Function(int) onShowBlur;
  final dynamic columnH;
  final PrintService printService;
  final List<Map<String, dynamic>> tickets;

  const TicketOptions({super.key, required this.onClose, required this.columnH, required this.onShowBlur, required this.columnHeight, required this.heigthCard, required this.ticketInfo, required this.printService, required this.tickets,
  });

  @override
  State<TicketOptions> createState() => _TicketOptionsState();
}

class _TicketOptionsState extends State<TicketOptions> {

  final GlobalKey _columnKey = GlobalKey();
  double _columnHeight = 0.0;
  PrintService printService = PrintService();
  late PrintService2 printService2;
  List<dynamic> ticketDetails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateHeight();
    });
    ticketDetails = widget.ticketInfo[4];
    print(ticketDetails);
  }

  void _calculateHeight() {
    final RenderBox? renderBox =
    _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _columnHeight = renderBox.size.height;
        widget.columnHeight(_columnHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: (){
          widget.onClose();
        },
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            child: Column(
              key: _columnKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                      height: widget.heigthCard,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                        vertical: MediaQuery.of(context).size.width * 0.009,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors3.whiteColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ticket ${widget.ticketInfo[0]}',
                                style: TextStyle(
                                  color: AppColors3.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width * 0.05,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Fecha: ${widget.ticketInfo[1]}",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Cantidad total: ${widget.ticketInfo[2]} pzs",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Importe: ",
                                style: TextStyle(
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                              Text(
                                "\$${widget.ticketInfo[3]}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors3.primaryColor,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.01),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                      vertical: MediaQuery.of(context).size.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors3.whiteColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors3.primaryColor.withOpacity(0.3),),
                              )
                            ),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => TestPDF(ticket: widget.tickets,),
                                    ),
                                  );
                                  widget.onClose();
                                },
                                style: const ButtonStyle(
                                  alignment: Alignment.centerLeft,
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Compartir   ',
                                      style: TextStyle(
                                          color: AppColors3.primaryColor
                                      ),
                                    ),
                                    Icon(Icons.share),
                                  ],
                                )
                            )
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () async {
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
                                PrintService2 printService2 = PrintService2(widget.printService.characteristic!);
                                try{
                                  Platform.isAndroid ? await printService2.connectAndPrintAndroideTicket(ticketDetails, 'assets/imgLog/logoTest.png') :
                                  await printService2.connectAndPrintIOSTicket(ticketDetails, 'assets/imgLog/logoTest.png');
                                } catch(e){
                                  print("Error al intentar imprimir: $e");
                                  showOverlay(context, const CustomToast(message: 'Error al intentar imprimir'));
                                }
                              }
                              widget.onClose();
                              //widget.onShowBlur(1);
                            },
                            style: const ButtonStyle(
                                alignment: Alignment.centerLeft
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Imprimir      ',
                                  style: TextStyle(
                                      color: AppColors3.primaryColor
                                  ),
                                ),
                                Icon(Icons.print),
                                      ]))
                                ])
                              ]))
                    ]))));
  }
}
