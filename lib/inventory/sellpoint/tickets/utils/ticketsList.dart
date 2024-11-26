import 'package:beaute_app/inventory/sellpoint/tickets/utils/listenerOnDateChanged.dart';
import 'package:beaute_app/inventory/sellpoint/tickets/utils/listenerRemoverOL.dart';
import 'package:beaute_app/inventory/sellpoint/tickets/utils/ticketOptions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../kboardVisibilityManager.dart';
import '../../../print/printConnections.dart';
import '../../../themes/colors.dart';
import '../../../stock/products/services/productsService.dart';
import '../services/salesServices.dart';

class Ticketslist extends StatefulWidget {
  final ListenerremoverOL listenerremoverOL;
  final void Function(int) onShowBlur;
  final Function(double) onOptnSize;
  final PrintService printService;
  final ListenerOnDateChanged listenerOnDateChanged;
  final String dateController;
  final void Function(String) onDateChanged;

  const Ticketslist({super.key, required this.onShowBlur, required this.onOptnSize, required this.listenerremoverOL, required this.printService, required this.listenerOnDateChanged, required this.dateController, required this.onDateChanged});

  @override
  State<Ticketslist> createState() => _TicketslistState();
}

class _TicketslistState extends State<Ticketslist> {

  double optnSize = 0;
  List<GlobalKey> ticketKeys = [];
  OverlayEntry? overlayEntry;
  double widgetHeight = 0.0;
  bool isLoading = false;
  List<Map<String, dynamic>> tickets = [];
  List<AnimationController> aniControllers = [];
  List<int> cantHelper = [];
  List<int> tapedIndices = [];
  List<dynamic> ticketInfo = [];
  PrintService printService = PrintService();
  late String formattedDate;
  List<Map<String, dynamic>> ticketTemp = [];

  late KeyboardVisibilityManager keyboardVisibilityManager;
  List<ExpansionTileController>? tileController = [];

  void itemCount (index, action){
    if(action == false){
      cantHelper[index] > 0 ? cantHelper[index]-- : cantHelper[index] = 0;
      if(cantHelper[index] == 0){
        tapedIndices.remove(index);
        aniControllers[index].reverse().then((_){
          aniControllers[index].reset();
        });
      }
    }else{
      cantHelper[index]++;
    }
  }

  Map<int, List<Map<String, dynamic>>> groupByTicket(List<Map<String, dynamic>> ticketProducts) {
    Map<int, List<Map<String, dynamic>>> groupedTickets = {};
    for (var product in ticketProducts) {
      if (!groupedTickets.containsKey(product['ticketID'])) {
        groupedTickets[product['ticketID']] = [];
      }
      groupedTickets[product['ticketID']]!.add(product);
    }
    return groupedTickets;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    keyboardVisibilityManager.dispose();
  }

  @override
  void initState() {
    super.initState();
    keyboardVisibilityManager = KeyboardVisibilityManager();
    ticketKeys = List.generate(products_global.length, (index) => GlobalKey());
    fetchSales(widget.dateController, widget.dateController).then((_){
      WidgetsBinding.instance.addPostFrameCallback((_){
        optnSize = ticketKeys[0].currentContext!.size!.height;
      });
    });
    widget.listenerremoverOL.registrarObservador((newValue){
      if(newValue == true){
        removeOverlay();
      }
    });
    widget.listenerOnDateChanged.registrarObservador((callback, initData, finalData) async {
      if(callback){
        await fetchSales(initData, finalData).then((_){
          WidgetsBinding.instance.addPostFrameCallback((_){
            optnSize = ticketKeys[0].currentContext!.size!.height;
          });
        });
      }
    });
  }

  Future<void> fetchSales(String? initData, String? finalData) async{
    setState(() {
      isLoading = true;
    });
    widget.onDateChanged(initData!);
    try{
      final salesService = SalesServices();
      final tickets2 = await salesService.fetchSales(initData, finalData);
      setState(() {
        tileController = [];
        tickets = tickets2;
        tickets2.sort((a, b) => b['id'].compareTo(a['id']));
        ticketKeys = List.generate(tickets.length, (index) => GlobalKey()); // Actualiza ticketKeys
        for (int i = 0; i <= tickets.length; i++) {
          tileController?.add(ExpansionTileController());
        }
        cantHelper = List.generate(tickets.length, (index) => 0);
        Future.delayed(Duration(milliseconds: 250));
        isLoading = false;
      });
    }catch (e) {
      print('Error fetching sales: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void colHeight (double colHeight) {
    widgetHeight = colHeight;
  }

  void showTicketOptions(int index) {
    tileController![index].isExpanded ? tileController![index].collapse() : null;
    ticketInfo.addAll([
      tickets[index]['id'],
      tickets[index]['fecha'],
      tickets[index]['cantidad'],
      tickets[index]['total'],
      tickets[index]['detalles'],
    ]);
    if (index >= 0 && index < tickets.length) {
      ticketTemp = [tickets[index]];
      print('holajeje $ticketTemp');
      removeOverlay();
      final key = ticketKeys[index];
      if (key.currentContext != null && key.currentContext!.findRenderObject() is RenderBox) {
        final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        final availableSpaceBelow = screenHeight - position.dy;

        double topPosition;

        if (availableSpaceBelow >= widgetHeight) {
          topPosition = position.dy;
        } else {
          topPosition = screenHeight - widgetHeight - MediaQuery.of(context).size.height * 0.03;
        }

        overlayEntry = OverlayEntry(
          builder: (context) {
            return Positioned(
              top: topPosition - 7,
              left: position.dx,
              width: size.width,
              child: IntrinsicHeight(
                child: TicketOptions(
                  heigthCard: optnSize,
                  onClose: removeOverlay,
                  columnHeight: colHeight,
                  onShowBlur: widget.onShowBlur,
                  columnH: null, 
                  ticketInfo: ticketInfo,
                  printService: widget.printService,
                  tickets: ticketTemp,
                ),
              ),
            );
          },
        );
        Overlay.of(context).insert(overlayEntry!);
        widget.onShowBlur(1);
      } else {
        print("RenderBox is null or not valid for ticket $index");
      }
    } else {
      print("Invalid index or no tickets available");
    }
  }

  void removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
      ticketInfo.clear();

    }
    for (var controller in aniControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
    if (mounted) {
      widget.onShowBlur(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final groupedTickets = groupByTicket(ticketProducts);
    return Container(
      color: AppColors.bgColor,
      child: !isLoading ? (
        tickets.isNotEmpty ? ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return Container(
                key: ticketKeys[index],
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03, right: MediaQuery.of(context).size.width * 0.03, bottom: MediaQuery.of(context).size.width * 0.03),
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(0.1),
                      offset: const Offset(4, 4),
                      blurRadius: 2,
                      spreadRadius: 0.1,
                    )
                  ],
                ),
                child: GestureDetector(
                  onLongPress: () {
                    keyboardVisibilityManager.hideKeyboard(context);
                    showTicketOptions(index);
                    widget.onShowBlur(2);
                  },
                  child: ExpansionTile(
                      controller: tileController![index],
                      iconColor: AppColors.bgColor,
                      collapsedIconColor: AppColors.primaryColor,
                      backgroundColor: AppColors.primaryColor,
                      collapsedBackgroundColor: Colors.transparent,
                      textColor: AppColors.bgColor,
                      collapsedTextColor: AppColors.primaryColor,
                      tilePadding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.04,
                          right: MediaQuery.of(context).size.width * 0.02,
                          top: MediaQuery.of(context).size.width * 0.01,
                          bottom: MediaQuery.of(context).size.width * 0.015
                      ),
                      initiallyExpanded: false,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2
                          )
                      ),
                      title: Text(
                        'Ticket ${tickets[index]['id']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
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
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                ),
                              ),
                              Text(
                                '${tickets[index]['fecha']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Cantidad total: ',
                                style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                ),
                              ),
                              Text(
                                '${tickets[index]['cantidad']} pzs',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Total: ',
                                style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04
                                ),
                              ),
                              Text(
                                '\$${tickets[index]['total']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.width * 0.04),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04, top: MediaQuery.of(context).size.width * 0.04, left: MediaQuery.of(context).size.width * 0.04),
                          decoration: const BoxDecoration(
                              color: AppColors.bgColor,
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              border: Border(
                                  top: BorderSide(color: AppColors.primaryColor, width: 2)
                              )
                          ),
                          child: Column(
                            children: tickets[index]['detalles'].map<Widget>((detalle) {
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.06),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${detalle['producto']['nombre']}',
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Cant.: ",
                                          style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: MediaQuery.of(context).size.width * 0.035),
                                        ),
                                        Text(
                                          '${detalle['cantidad']} pzs',
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
                                              color: AppColors.primaryColor,
                                              fontSize: MediaQuery.of(context).size.width * 0.035),
                                        ),
                                        Text(
                                          '\$${detalle['precio']}',
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
                                              color: AppColors.primaryColor,
                                              fontSize: MediaQuery.of(context).size.width * 0.035),
                                        ),
                                        Text(
                                          '\$${detalle['cantidad'] * double.parse(detalle['precio'])}',
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
                              );
                            }).toList(),
                          ),
                        )
                      ]
                  ),
                )
            );
          },
        ) : const Center(
          child: Text(
            'No hay tickets correspondientes a la fecha seleccionada',
            style: TextStyle(
                color: AppColors.primaryColor
            ),
          ),
        )
      ) : const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      )
    );
  }
}