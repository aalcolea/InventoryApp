import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../globalVar.dart';
import '../../inventory/admin.dart';
import '../views/login.dart';

class DatabaseHelpers {
  final BuildContext context;

  DatabaseHelpers(this.context);


  Future<void> checkConnectionAndLoginStatus(bool isConnected) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isConnected = connectivityResult != ConnectivityResult.none;

    if (isConnected) {
      await checkLoginStatus(isConnected);
    } else {
      await loadLocalData();
    }
  }

  Future<void> checkLoginStatus(bool isConnected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    await Future.delayed(const Duration(seconds: 2));

    if (token != null) {
      var response = await http.get(
        Uri.parse('https://beauteapp-dd0175830cc2.herokuapp.com/api/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        int userId = data['user']['id'];
        SessionManager.instance.isDoctor = (data['user']['id'] == 1 || data['user']['id'] == 2);
        SessionManager.instance.Nombre = data['user']['name'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => adminInv()),
        );
      } else {
        prefs.remove('jwt_token');
        goToLogin();
      }
    } else {
      goToLogin();
    }
  }

  Future<void> loadLocalData() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => adminInv()),
    );
  }


  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }
}
