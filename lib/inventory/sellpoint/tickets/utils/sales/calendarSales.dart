import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../../../helpers/themes/colors.dart';

class SalesCalendar extends StatefulWidget {
  final String dateInit;
  final void Function(String, bool) onDayToAppointFormSelected;
  SalesCalendar({Key? key, required this.onDayToAppointFormSelected, required this.dateInit}) : super(key: key);

  @override
  State<SalesCalendar> createState() => _SalesCalendarState();
}

class _SalesCalendarState extends State<SalesCalendar> {

  TextEditingController saleDateController = TextEditingController();

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  final CalendarController _calendarController = CalendarController();
  int initMonth = 0;
  int? currentMonth = 0;
  int? visibleYear = 0;
  DateTime now = DateTime.now();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    saleDateController.text = widget.dateInit;
    selectedDate = DateFormat('yyyy-MM-dd').parse(widget.dateInit);
    initMonth = now.month;
    currentMonth = _calendarController.displayDate?.month;
    visibleYear = now.year;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            alignment: Alignment.topRight,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width  * 0.02,
                      ),
                      padding: EdgeInsets.only(
                        top:  MediaQuery.of(context).size.width * 0.02,
                        bottom:  MediaQuery.of(context).size.width * 0.02,
                        left:  MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02,),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(-10)),
                        color: AppColors3.secundaryColor,
                      ),
                      child: TextFormField(
                        enableInteractiveSelection: false,
                        controller: saleDateController,
                        readOnly: true,
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02),
                          isDense: true,
                          isCollapsed: true,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.width * 0.1,
                            minWidth: 0,
                          ),
                          hintText: 'DD-MM--AA',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors3.whiteColor,
                        size: MediaQuery.of(context).size.width * 0.055,
                      ),
                      onPressed: () {
                        int previousMonth = currentMonth! - 1;
                        int previousYear = visibleYear!;
                        if (previousMonth < 1) {
                          previousMonth = 12;
                          previousYear--;
                        }
                        _calendarController.displayDate =
                            DateTime(previousYear, previousMonth, 1);
                      },
                    ),
                    Text(
                      currentMonth != null
                          ? '${getMonthName(currentMonth!)} $visibleYear'
                          : '${getMonthName(initMonth)} $visibleYear',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: AppColors3.whiteColor),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors3.whiteColor,
                        size: MediaQuery.of(context).size.width * 0.055,
                      ),
                      onPressed: () {
                        int nextMonth = currentMonth! + 1;
                        int nextYear = visibleYear!;
                        if (nextMonth > 12) {
                          nextMonth = 1;
                          nextYear++;
                        }
                        _calendarController.displayDate =
                            DateTime(nextYear, nextMonth, 1);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: AppColors3.secundaryColor,//AppColors32.secundaryColor,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: AppColors3.secundaryColor, width: 1.2),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: SfCalendar(
                          headerHeight: 0,
                          firstDayOfWeek: 1,
                          view: CalendarView.month,
                          controller: _calendarController,
                          onTap: (CalendarTapDetails details) {
                            if (details.date != null) {
                              DateTime selectedDate = details.date!;
                              DateTime now = DateTime.now();
                              if (selectedDate.isAfter(
                                  DateTime(now.year, now.month, now.day))) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      padding: EdgeInsets.only(
                                        top: MediaQuery.of(context).size.width * 0.08,
                                        bottom: MediaQuery.of(context).size.width * 0.08,
                                        left: MediaQuery.of(context).size.width * 0.02,
                                      ),
                                      content: Text('No se pueden seleccionar fechas futuras',
                                        style: TextStyle(
                                            color: AppColors3.whiteColor,
                                            fontSize: MediaQuery.of(context).size.width * 0.045),
                                      )),
                                );
                              } else {
                                String dateOnly = DateFormat('yyyy-MM-dd').format(selectedDate);
                                widget.onDayToAppointFormSelected(dateOnly, false);
                              }
                            }
                          },
                          onViewChanged: (ViewChangedDetails details) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              int? visibleMonthController = _calendarController.displayDate?.month;
                              currentMonth = visibleMonthController;
                              int? visibleYearController = _calendarController.displayDate?.year;
                              visibleYear = visibleYearController;
                              setState(() {});
                            });
                          },
                          initialDisplayDate: selectedDate,
                          monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                            final bool isToday =
                                details.date.month == DateTime.now().month &&
                                    details.date.day == DateTime.now().day &&
                                    details.date.year == DateTime.now().year;

                            final bool isInCurrentMonth =
                                details.date.month == currentMonth &&
                                    details.date.year == visibleYear;
                            final bool dateToShow =
                                details.date.month == selectedDate.month &&
                                    details.date.day == selectedDate.day &&
                                    details.date.year == selectedDate.year;



                            if (selectedDate == DateTime.now()) {
                              return Center(
                                child: Container(
                                  width: null,
                                  height: null,
                                  decoration: BoxDecoration(
                                    color: AppColors3.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors3.blackColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      details.date.day.toString(),
                                      style: TextStyle(
                                        color: AppColors3.whiteColor,
                                        fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (dateToShow) {
                              return Container(
                                width: null,
                                height: null,
                                decoration: BoxDecoration(
                                  color: AppColors3.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors3.primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    details.date.day.toString(),
                                    style: TextStyle(
                                      color: AppColors3.whiteColor,
                                      fontSize:
                                      MediaQuery.of(context).size.width * 0.05,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors3.whiteColor,
                                        border: Border.all(
                                          color: AppColors3.greyColor,
                                          width: 0.2,
                                        ),
                                      ),
                                      child: Center(
                                          child: Text(details.date.day.toString(),
                                              style: TextStyle(
                                                color: isInCurrentMonth
                                                    ? AppColors3.blackColor
                                                    : AppColors3.primaryColor.withOpacity(0.4),
                                                fontSize: MediaQuery.of(context).size.width * 0.05,
                                              )))));
                            }
                          }))))
        ]);
  }
}