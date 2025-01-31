import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/services/salesServices.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/listenerOnDateChanged.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/listenerRemoverOL.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/sales/calendarSales.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/sales/listenerQuery.dart';
import 'package:inventory_app/inventory/sellpoint/tickets/utils/ticketsList.dart';
import '../../../deviceThresholds.dart';
import '../../deviceManager.dart';
import '../../print/printConnections.dart';
import '../../themes/colors.dart';
import '../../../regEx.dart';
import '../../kboardVisibilityManager.dart';
import '../tickets/utils/salesList.dart';

class SalesHistory extends StatefulWidget {

  final PrintService printService;

  const SalesHistory({super.key, required this.printService});

  @override
  State<SalesHistory> createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> with SingleTickerProviderStateMixin, WidgetsBindingObserver  {

  ListenerremoverOL listenerremoverOL = ListenerremoverOL();
  ListenerQuery listenerQuery = ListenerQuery();
  ListenerOnDateChanged listenerOnDateChanged = ListenerOnDateChanged();
  late AnimationController animationController;
  late Animation<double> opacidad;
  late String formattedDate;
  late KeyboardVisibilityManager keyboardVisibilityManager;
  //
  double? screenWidth;
  double? screenHeight;
  double optSize = 0;
  bool showBlurr = false;
  int blurShowed = 0;
  int selectedPage = 0;
  //
  TextEditingController seekController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  FocusNode seekNode = FocusNode();
  FocusNode dateNode = FocusNode();
  PageController pageController = PageController();
  final salesService = SalesServices();
  String longDate = '';

  List<Map<String, dynamic>> tickets = [];

  void onOptnSize(double optSize){
    setState(() {
      this.optSize = optSize;
    });
  }

  void onFilterProducts (){
    listenerQuery.setChange(seekController.text);
  }

  void onDateChanged(){
    listenerOnDateChanged.setChange(true, dateController.text, dateController.text);
  }

  void _onDateToAppointmentForm(
      String dateToAppointmentForm, bool showCalendar) {
    setState(() {
      animationController.reverse().then((_){
        showBlurr = showCalendar;
        animationController.reset();
      });
      DateTime parsedDate = DateTime.parse(dateToAppointmentForm);
      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      longDate = DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(parsedDate);
      dateController.text = formattedDate;
      onDateChanged();
    });
  }

  void _onShowBlurr(int showBlurr) {
    setState(() {
      blurShowed = showBlurr;
      if (blurShowed == 0) {
        this.showBlurr = false;
      } else {
        this.showBlurr = true;
      }
    });
  }

  var orientation = Orientation.portrait;
  bool isTablet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar los valores usando MediaQuery cuando el contexto está disponible
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    orientation = mediaQuery.orientation;

    /*setState(() {
      isTablet = isTabletDevice(screenWidth!, screenHeight!, orientation);
    });*/
  }

  /*bool isTabletDevice(double width, double height, Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return height > DeviceThresholds.minTabletHeightPortrait &&
          width > DeviceThresholds.minTabletWidth;
    } else {
      return height > DeviceThresholds.minTabletHeightLandscape &&
          width > DeviceThresholds.minTabletWidthLandscape;
    }
  }*/



/*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    orientation = MediaQuery.of(context).orientation;
    if(screenHeight! > 550 && screenWidth! > 940 ){
      isTablet = true;
    }
  }*/

  late DeviceInfo deviceInfo;


  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {
        deviceInfo = DeviceInfo(); // Recalcular cuando cambian las métricas
      });
    }
  }

  /*@override
  void didChangeMetrics() {
    if(mounted){
      setState(() {
        _initializeDeviceType();
      });
    }
  }*/

/*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }*/

  void filterSales(text){
    setState(() {
      listenerQuery.setChange(seekController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    opacidad = Tween(begin: 0.0, end:  1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener((){
      if(mounted){
        setState(() {
        });
      }

    });
    keyboardVisibilityManager = KeyboardVisibilityManager();
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    dateController.text = formatter.format(now);
    longDate = DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(now);
    WidgetsBinding.instance.addObserver(this);
    deviceInfo = DeviceInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }
  bool isLoading = false;

  void removerOverL(){
    listenerremoverOL.setChange(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgColor,
                leadingWidth: MediaQuery.of(context).size.width,
                pinned: true,
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        size: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.08 : deviceInfo.orientation == Orientation.portrait ?
                        MediaQuery.of(context).size.width * 0.08 : MediaQuery.of(context).size.height * 0.08,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTabButton('Tickets', 0),
                            Container(
                              width: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.01 :
                              deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.01 : MediaQuery.of(context).size.height * 0.01,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.7),
                              ),
                            ),
                            _buildTabButton('Ventas', 1),
                          ],
                        )),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.12,)

                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.bgColor,
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03, vertical: MediaQuery.of(context).size.width * 0.02),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.005, bottom: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: AppColors.bgColor,
                              ),
                              margin: EdgeInsets.only(right: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.02 : deviceInfo.orientation == Orientation.portrait ?
                              MediaQuery.of(context).size.width * 0.02 : MediaQuery.of(context).size.height * 0.02),
                              width: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.32 : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.32
                              : MediaQuery.of(context).size.height * 0.32,
                              height: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.105 : deviceInfo.orientation == Orientation.portrait ?
                              MediaQuery.of(context).size.width * 0.105 : MediaQuery.of(context).size.height * 0.105,
                              child: TextFormField(
                                enableInteractiveSelection: false,
                                readOnly: true,
                                controller: dateController,
                                focusNode: dateNode,
                                decoration: InputDecoration(
                                  isDense: true,
                                  floatingLabelBehavior: dateController.text.isEmpty ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
                                  hintText: dateController.text,
                                  hintStyle: TextStyle(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.035 : deviceInfo.orientation == Orientation.portrait ?
                                    MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 2.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.04 : deviceInfo.orientation == Orientation.portrait ?
                                  MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                                ),
                                onTap: (){
                                  setState(() {
                                    showBlurr = true;
                                    blurShowed = 1;
                                    animationController.forward();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: AppColors.bgColor,
                                  ),
                                  child: TextFormField(
                                    controller: seekController,
                                    focusNode: seekNode,
                                    enabled: selectedPage == 0 ? false : true,
                                    inputFormatters: [
                                      RegEx(type: InputFormatterType.alphanumeric),
                                    ],
                                    decoration: InputDecoration(
                                        isDense: false,
                                        constraints: BoxConstraints(
                                          maxHeight: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.105 : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.105
                                          : MediaQuery.of(context).size.height * 0.105,
                                        ),
                                        hintText: 'Buscar por nombre o categoria...',
                                        hintStyle: TextStyle(
                                          color: selectedPage == 0 ?  AppColors.primaryColor.withOpacity(0.3) :  AppColors.primaryColor,
                                          fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.035 : deviceInfo.orientation == Orientation.portrait ?
                                          MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: selectedPage == 0 ?  AppColors.primaryColor.withOpacity(0.2) :  AppColors.primaryColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: selectedPage == 0 ?  AppColors.primaryColor.withOpacity(0.2) :  AppColors.primaryColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: selectedPage == 0 ?  AppColors.primaryColor.withOpacity(0.2) :  AppColors.primaryColor, width: 2.0),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        suffixIcon: seekController.text.isNotEmpty ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              seekController.clear();
                                              filterSales('');
                                            });
                                          },
                                          icon: Icon(
                                            CupertinoIcons.clear,
                                            size: MediaQuery.of(context).size.width * 0.05,
                                            color: AppColors.primaryColor,
                                          ),
                                        ) : null
                                    ),
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.0425 : deviceInfo.orientation == Orientation.portrait ?
                                      MediaQuery.of(context).size.width * 0.0425 : MediaQuery.of(context).size.height * 0.0425,
                                    ),
                                    onChanged: (text){
                                      filterSales(text);
                                    },
                                  ),
                                )
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: dateController.text.isEmpty ? false : true,
                        child: Container(
                          margin: EdgeInsets.only(top: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.03 : deviceInfo.orientation == Orientation.portrait ?
                          MediaQuery.of(context).size.width * 0.03 :  MediaQuery.of(context).size.height * 0.03),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            textAlign: TextAlign.left,
                            '*Productos vendidos el $longDate',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.04 : deviceInfo.orientation == Orientation.portrait ?
                              MediaQuery.of(context).size.width * 0.04 : MediaQuery.of(context).size.height * 0.04,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: PageView(
                  controller: pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      selectedPage = page;
                      seekController.text = '';
                    });
                  },
                  children: [
                    //TODO si los listener presentan mas problemas usar esta structura
                    /*ListView.builder(
                  itemCount: 100000, // Puedes usar números muy grandes
                  itemBuilder: (context, index) {
                    return ListTile(title: Text('Item $index'));
                  },
                );*/

                    //
                    Ticketslist(
                      onShowBlur: _onShowBlurr,
                      onOptnSize: onOptnSize,
                      listenerremoverOL: listenerremoverOL,
                      printService: widget.printService,
                      listenerOnDateChanged: listenerOnDateChanged,
                      dateController: dateController.text,
                      onDateChanged: (fechaRecibida) => dateController.text = fechaRecibida,
                      isTablet: deviceInfo.isTablet,
                    ),
                    SalesList(
                      onShowBlur: _onShowBlurr,
                      listenerOnDateChanged: listenerOnDateChanged,
                      dateController: dateController.text,
                      onDateChanged: (fechaRecibida) => dateController.text = fechaRecibida,
                      printService: widget.printService,
                      listenerQuery: listenerQuery,
                      isTablet: deviceInfo.isTablet,
                    ),
                  ],
                ),
              ),
            ],
          ),
          blurShowed == 1 ? AnimatedBuilder(
              animation: animationController,
              child: Visibility(
                visible: showBlurr,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      animationController.reverse().then((_){
                        showBlurr = false;
                        animationController.reset();
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.blackColor.withOpacity(0.1),
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: !deviceInfo.isTablet ? EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.25,
                            bottom: MediaQuery.of(context).size.width * 0.03,
                            left: MediaQuery.of(context).size.width * 0.02,
                            right: MediaQuery.of(context).size.width * 0.02,
                          ) : orientation == Orientation.portrait ? EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.25,
                            bottom: MediaQuery.of(context).size.width * 0.03,
                            left: MediaQuery.of(context).size.width * 0.02,
                            right: MediaQuery.of(context).size.width * 0.02,
                          ) : EdgeInsets.only(
                            top: MediaQuery.of(context).size.height   * 0.16,
                            bottom: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.height * 0.02,
                            right: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.03
                                : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.03
                                    : MediaQuery.of(context).size.height * 0.0),
                                padding: !deviceInfo.isTablet ? EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.03,
                                    bottom: MediaQuery.of(context).size.width * 0.03) :
                                deviceInfo.orientation == Orientation.portrait ?
                                EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width * 0.03,
                                    right: MediaQuery.of(context).size.width * 0.03,
                                    bottom: MediaQuery.of(context).size.width * 0.03) :
                                EdgeInsets.only(
                                    left: MediaQuery.of(context).size.height * 0.03,
                                    right: MediaQuery.of(context).size.height * 0.03,
                                    bottom: MediaQuery.of(context).size.height * 0.03),
                                width: MediaQuery.of(context).size.width,
                                height: !deviceInfo.isTablet ? MediaQuery.of(context).size.height * 0.45 :
                                deviceInfo.orientation == Orientation.portrait ?
                                MediaQuery.of(context).size.height * 0.45 : MediaQuery.of(context).size.height * 0.68,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent, width: 2.0),
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ), child: SalesCalendar(
                                  isTablet: deviceInfo.isTablet,
                                  onDayToAppointFormSelected: _onDateToAppointmentForm, dateInit: dateController.text),
                              ),
                            ],
                          )
                      ),
                    ),
                  ),
                ),
              ),
              builder: (context, selCalendarOp,){
                return Opacity(
                    opacity: opacidad.value,
                    child: selCalendarOp);
              }) : Visibility(
              visible: showBlurr,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: GestureDetector(
                  onTap: () {
                    removerOverL();
                    setState(() {
                      showBlurr = false;
                      blurShowed = 0;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.blackColor.withOpacity(0.1),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int pageIndex) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedPage = pageIndex;
          pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 250), curve: Curves.linear);
        });
      },
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: selectedPage == pageIndex
            ? TextStyle(
          color: AppColors.primaryColor,
          fontSize:  !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.06  : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.06 : MediaQuery.of(context).size.height * 0.06,/* MediaQuery.of(context).size.width * 0.06,*/
          fontWeight: FontWeight.bold,
        )
            : TextStyle(
          color: AppColors.primaryColor.withOpacity(0.2),
          fontSize: !deviceInfo.isTablet ? MediaQuery.of(context).size.width * 0.035  : deviceInfo.orientation == Orientation.portrait ? MediaQuery.of(context).size.width * 0.035 : MediaQuery.of(context).size.height * 0.035,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
