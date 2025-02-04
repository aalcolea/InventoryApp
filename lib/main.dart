import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inventory_app/inventory/deviceManager.dart';
import 'package:provider/provider.dart';
import 'helpers/services/databaseHelpers.dart';
import 'helpers/themes/colors.dart';
import 'helpers/views/login.dart';
import 'inventory/sellpoint/cart/services/cartService.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('Permiso de notificación aceptado: ${settings.authorizationStatus}');

  bool isSimulator = await isRunningOnSimulator();
  print('es un simulador de ios? $isSimulator');

  if (!isSimulator) {
    try {
      String? fcmToken = await messaging.getToken();
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Error al obtener el token FCM: $e');
    }
  } else {
    print('Ejecutando en un simulador de iOS');
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensaje recibido en primer plano: ${message.notification?.title}');
  });

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}
Future<bool> isRunningOnSimulator() async {
  if (!Platform.isIOS) return false;
  return kDebugMode && !kIsWeb;
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors3.primaryColor),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const Login(),
      },
      debugShowCheckedModeBanner: false,
      ///pendiente unificacion
      home: SplashScreen(),
      navigatorObservers: [routeObserver],
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool isConnected = false;
  late DatabaseHelpers dbHelpers;
  @override
  void initState() {
    super.initState();
    dbHelpers = DatabaseHelpers(context);
    dbHelpers.checkConnectionAndLoginStatus(isConnected);
  }
  void goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors3.primaryColor,
            ),
            SizedBox(height: 20),
            Text('Cargando...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
