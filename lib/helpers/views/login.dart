import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../services/auth_service.dart';
import '../styles/ladingDraw.dart';
import '../themes/colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isDocLog = true;
  int userIdHelper = 0;
  bool showPinEntryScreen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LadingDraw(),
        Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width * 0.32),
                child: CircleAvatar(
                  backgroundColor: AppColors3.whiteColor,
                  radius: MediaQuery.of(context).size.height * 0.21,
                  /*backgroundImage:
                      const AssetImage("assets/imgLog/logoBeauteWhite.png")*/
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.095,
                  right: MediaQuery.of(context).size.width * 0.095,
                  bottom: MediaQuery.of(context).size.width * 0.065,
                ),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        isDocLog = true;
                        userIdHelper = 1;
                        /*   Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PinEntryScreen(
                                  userId: 1,
                                  docLog: isDocLog,
                                )),
                      );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: AppColors3.secundaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: AppColors3.secundaryColor, width: 2),
                      ),
                      backgroundColor: AppColors3.secundaryColor,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.035, right: MediaQuery.of(context).size.width * 0.015),
                          child: SvgPicture.asset(
                            'assets/imgLog/docVector2.svg',
                            color: AppColors3.primaryColor,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: AppColors3.primaryColor,
                            border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Usuario 1',
                            style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.095,
                  right: MediaQuery.of(context).size.width * 0.095,
                  bottom: MediaQuery.of(context).size.width * 0.065,
                ),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        userIdHelper = 2;
                        isDocLog = true;
                        /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PinEntryScreen(
                                  userId: 2,
                                  docLog: isDocLog,
                                )),
                      );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: AppColors3.secundaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: AppColors3.secundaryColor, width: 2),
                      ),
                      backgroundColor: AppColors3.secundaryColor,
                    ),
                    child: Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).size.width * 0.035, right: MediaQuery.of(context).size.width * 0.015),
                            child: SvgPicture.asset(
                                'assets/imgLog/docVector2.svg', color: AppColors3.primaryColor,) /*Icon(
                            Icons.person,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.1,
                          ),*/
                            ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: AppColors3.primaryColor,
                            border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Usuario 2',
                            style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.065,
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.095,
                    right: MediaQuery.of(context).size.width * 0.095,
                    bottom: MediaQuery.of(context).size.width * 0.08),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showPinEntryScreen = true;
                        userIdHelper = 3;
                        isDocLog = false;
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PinEntryScreen(
                                userId: 3,
                                docLog: isDocLog,
                              )),
                        );*/
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 10,
                      surfaceTintColor: AppColors3.secundaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                            color: AppColors3.secundaryColor, width: 2),
                      ),
                      backgroundColor: AppColors3.secundaryColor,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.035, right: MediaQuery.of(context).size.width * 0.015),
                          child: SvgPicture.asset(
                                  'assets/imgLog/asisVector.svg', color: AppColors3.primaryColor,)
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.015,
                              right: MediaQuery.of(context).size.width * 0.15),
                          height: MediaQuery.of(context).size.width * 0.09,
                          width: MediaQuery.of(context).size.width * 0.006,
                          decoration: BoxDecoration(
                            color: AppColors3.primaryColor,
                            border: Border.all(width: 0.5, color: AppColors3.primaryColor),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Asistente',
                            style: TextStyle(
                              color: AppColors3.primaryColor,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.003,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors3.primaryColor,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(2, -0),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),

        ///
        Visibility(
          visible: showPinEntryScreen,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PinEntryScreen(
              userId: userIdHelper,
              docLog: isDocLog,
              onCloseScreeen: (closeScreen) {
                setState(() {
                  closeScreen == true
                      ? showPinEntryScreen = false
                      : showPinEntryScreen == true;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
