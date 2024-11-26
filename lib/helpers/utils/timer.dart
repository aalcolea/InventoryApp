import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../themes/colors.dart';

class TimerFly extends StatefulWidget {
  final void Function(bool, TextEditingController, int) onTimeChoose;

  TimerFly({super.key, required this.onTimeChoose});

  @override
  State<TimerFly> createState() => _TimerFlyState();
}

class _TimerFlyState extends State<TimerFly> {
  final ScrollController hourcontroller =
      FixedExtentScrollController(initialItem: 12);
  final ScrollController minsController =
      FixedExtentScrollController(initialItem: 0);
  final ScrollController AmPmController =
      FixedExtentScrollController(initialItem: 0);
  final timeController = TextEditingController();

  int selectedIndexAmPm = 0;
  int selectedIndexMins = 0;
  int selectedIndexHours = 0;
  int hour = 0;
  int minuts = 0;

  // 0 = AM, 1 = PM
  bool _isTimerShow = false;
  double? smallestDimension;
  double? diameterRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    smallestDimension = MediaQuery.of(context).size.shortestSide;
    diameterRatio = (smallestDimension! * 0.0028);
    print(diameterRatio);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Row(children: [
        ///hrs
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.29,
            child: ListWheelScrollView.useDelegate(
                controller: hourcontroller,
                perspective: 0.001,
                diameterRatio: 0.96,
                physics: const FixedExtentScrollPhysics(),
                itemExtent: MediaQuery.of(context).size.width * 0.18,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedIndexHours = value;
                    print(selectedIndexHours);
                  });
                },
                childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(12, (index) {
                  final Color colorforhours = index == selectedIndexHours
                      ? AppColors3.primaryColor
                      : Colors.grey;

                  return Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: index != selectedIndexHours
                              ? MediaQuery.of(context).size.width * 0.04
                              : MediaQuery.of(context).size.width * 0.0),
                      decoration: index == selectedIndexHours
                          ? const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors3.primaryColor,
                                  width: 2,
                                ),
                                bottom: BorderSide(
                                  color: AppColors3.primaryColor,
                                  width: 2,
                                ),
                              ),
                              color: Colors.white,
                            )
                          : index == 11
                              ? const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                )
                              : index == 1
                                  ? const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                      child: Center(
                          child: Text(index == 0 ? '12' : index.toString(),
                              style: TextStyle(
                                fontSize: index == selectedIndexHours
                                    ? MediaQuery.of(context).size.width * 0.11
                                    : MediaQuery.of(context).size.width * 0.12,
                                color: colorforhours,
                              ))));
                })))),
        Text(
          ':',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.125,
            color: AppColors3.primaryColor,
          ),
        ),

        ///mins

        SizedBox(
            width: MediaQuery.of(context).size.width * 0.29,
            child: ListWheelScrollView.useDelegate(
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedIndexMins = value;
                    print(selectedIndexMins);
                  });
                },
                controller: minsController,
                perspective: 0.001,
                diameterRatio: 0.96,
                physics: const FixedExtentScrollPhysics(),
                itemExtent: MediaQuery.of(context).size.width * 0.18,
                childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(60, (index) {
                  final Color colorformins = index == selectedIndexMins
                      ? AppColors3.primaryColor
                      : Colors.grey;
                  return Container(
                      decoration: index == selectedIndexMins
                          ? const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors3.primaryColor,
                                  width: 2,
                                ),
                                bottom: BorderSide(
                                  color: AppColors3.primaryColor,
                                  width: 2,
                                ),
                              ),
                              color: Colors.white,
                            )
                          : index == 59 && index == 59
                              ? const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                )
                              : index == 1
                                  ? const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                      child: Center(
                          child: Text(index < 10 ? '0$index' : index.toString(),
                              style: TextStyle(
                                  fontSize: index == selectedIndexMins
                                      ? MediaQuery.of(context).size.width * 0.11
                                      : MediaQuery.of(context).size.width *
                                          0.12,
                                  color: colorformins))));
                })))),

        ///am/pm
        Container(
            margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.0,
                left: MediaQuery.of(context).size.width * 0.03),
            width: MediaQuery.of(context).size.width * 0.23,
            child: ListWheelScrollView.useDelegate(
                controller: AmPmController,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedIndexAmPm = value;
                    print(selectedIndexAmPm);
                  });
                },
                perspective: 0.001,
                diameterRatio: 0.96,
                physics: const FixedExtentScrollPhysics(),
                itemExtent: MediaQuery.of(context).size.width * 0.18,
                childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 2,
                    builder: (context, index) {
                      final Color colorforitems = index == selectedIndexAmPm
                          ? AppColors3.primaryColor
                          : Colors.grey;
                      final String text = index == 0 ? 'p.m' : 'a.m';
                      return Container(
                          decoration: index == selectedIndexAmPm
                              ? const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors3.primaryColor,
                                      width: 2,
                                    ),
                                    bottom: BorderSide(
                                      color: AppColors3.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  color: Colors.white,
                                )
                              : index - 1 == selectedIndexAmPm
                                  ? const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                    )
                                  : index + 1 == selectedIndexAmPm
                                      ? const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                        )
                                      : null,
                          child: Center(
                              child: Text(text,
                                  style: TextStyle(
                                      fontSize: index == selectedIndexAmPm
                                          ? MediaQuery.of(context).size.width *
                                              0.11
                                          : MediaQuery.of(context).size.width *
                                              0.12,
                                      color: colorforitems))));
                    })))
      ])),
      Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.width * 0.04,
          ),
          child: ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                selectedIndexAmPm == 1
                    ? selectedIndexHours == 0
                        ? hour = 24
                        : hour = selectedIndexHours
                    : selectedIndexAmPm == 0
                        ? selectedIndexHours == 0
                            ? hour = 12
                            : hour = selectedIndexHours + 12
                        : null;

                DateTime fullTime = DateTime(
                    now.year, now.month, now.day, hour, selectedIndexMins);
                String formattedTime = DateFormat('HH:mm:ss').format(fullTime);
                setState(() {
                  print('selectedDate>>> ${fullTime.hour}');

                  timeController.text = formattedTime;
                });

                widget.onTimeChoose(
                  _isTimerShow,
                  timeController,
                  selectedIndexAmPm,
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 2,
                surfaceTintColor: Colors.white,
                splashFactory: InkRipple.splashFactory,
                padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(color: AppColors3.primaryColor, width: 2),
                ),
                backgroundColor: AppColors3.primaryColor,
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 22, color: Colors.white),
              )))
    ]);
  }
}
