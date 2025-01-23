import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../helpers/utils/showToast.dart';
import '../../helpers/utils/toastWidget.dart';
import '../listenerPrintService.dart';

class PrintService extends ChangeNotifier {
  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }

/*  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 12+
         if (await Permission.bluetoothScan.isDenied) {
          await Permission.bluetoothScan.request();
        }
         if (await Permission.bluetooth.isDenied) {
          await Permission.bluetooth.request();
        }
         if (await Permission.bluetoothAdvertise.isDenied) {
          await Permission.bluetoothAdvertise.request();
        }
          if (await Permission.bluetoothConnect.isDenied) {
          await Permission.bluetoothConnect.request();
        }
          if (await Permission.location.isDenied) {
          await Permission.location.request();
        }
      }
    }
  }*/

  Future<bool> requestBluetoothPermissions(context) async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 31) {
        // Android 12+ (API 31+)
        if (await Permission.bluetoothScan.isDenied) {
          await Permission.bluetoothScan.request();
        }
        if (await Permission.bluetooth.isDenied) {
          await Permission.bluetooth.request();
        }
        if (await Permission.bluetoothAdvertise.isDenied) {
          await Permission.bluetoothAdvertise.request();
        }
        if (await Permission.bluetoothConnect.isDenied) {
          await Permission.bluetoothConnect.request();
        }
      }

      if (androidInfo.version.sdkInt >= 29) {
        // Android 10+ (API 29+): Ubicación requerida para descubrir dispositivos Bluetooth
        if (await Permission.location.isDenied) {
          await Permission.location.request();
        }
      }

      // Manejar permisos denegados permanentemente
      if (await Permission.bluetoothScan.isPermanentlyDenied ||
          await Permission.bluetooth.isPermanentlyDenied ||
          await Permission.bluetoothAdvertise.isPermanentlyDenied ||
          await Permission.bluetoothConnect.isPermanentlyDenied ||
          await Permission.location.isPermanentlyDenied) {
        showOverlay(context, const CustomToast(message: 'Permisos denegado permanentemente hay que abrir configuraciones '
        ));
        await openAppSettings();
        return false;
      }
      return (await Permission.bluetoothScan.isGranted) &&
          (await Permission.bluetooth.isGranted) &&
          (await Permission.bluetoothAdvertise.isGranted) &&
          (await Permission.bluetoothConnect.isGranted) &&
          (await Permission.location.isGranted);
    }

    return false;
  }

  FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;
  //StreamSubscription<BluetoothDeviceState>? _connectionSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  bool? isConnect;
  ListenerPrintService listenerPrintService = ListenerPrintService();
  String nameTargetDevice = 'MP210';

  /* Future<void> connectToBluetoothDevice(context) async {
    PermissionStatus bluetoothScanStatus;
    PermissionStatus bluetoothConnectStatus;
    PermissionStatus locationStatus;

    bluetoothScanStatus = await Permission.bluetoothScan.request();
    bluetoothConnectStatus = await Permission.bluetoothConnect.request();
    locationStatus = await Permission.location.request();

    if (bluetoothScanStatus.isGranted && bluetoothConnectStatus.isGranted && locationStatus.isGranted) {
      try {
        scanForDevices(context);
      } catch (e) {
        print("Error al conectar: $e");
      }
    } else {
      listenerPrintService.setChange(2, false);
      print("Permisos de Bluetooth no concedidos.");
    }
  } */ Future<void> connectToBluetoothDevice(context) async {
    bool permisionsGranted = await requestBluetoothPermissions(context);

    if (permisionsGranted) {
      try {
        scanForDevices(context);
      } catch (e) {
        print("Error al conectar: $e");
      }
    } else {
      listenerPrintService.setChange(2, false);
      print("Permisos de Bluetooth no concedidos.");
      await openAppSettings();
    }
  }
  Future<void> ensureCharacteristicAvailable() async {
    if (characteristic == null && selectedDevice != null) {
      await discoverServices(selectedDevice!);
    }
    int retryCount = 0;
    while (characteristic == null && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }
    if (characteristic == null) {
      print('error $characteristic');
      throw Exception("Error: Característica de impresión no disponible");
    }
  }
  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
          characteristic = charac;
          listenerPrintService.setChange(1, true);
          notifyListeners();
          return;
        }
      }
    }
  }


/*
  void sendMessage(String message) async {
    if (characteristic != null) {
      print('char android $characteristic');
      List<int> bytes = utf8.encode(message + "\n");
      await characteristic!.write(bytes, withoutResponse: true);
    }
  }
*/
  void sendMessage(String message) async {
    if (characteristic != null) {
      List<int> bytes = utf8.encode(message + "\n");
      int retryCount = 0;
      bool success = false;
      while (!success && retryCount < 3) {
        try {
          await characteristic!.write(bytes, withoutResponse: true);
          success = true;
        } catch (e) {
          retryCount++;
          print("Retry $retryCount: $e");
          await Future.delayed(Duration(milliseconds: 50)); // Pausa antes del próximo intento
        }
      }
      if (!success) {
        print("Error: No se pudo enviar el mensaje después de varios intentos.");
      }
    }
  }

/*
  void initDeviceStatus() {
    isConnect = selectedDevice != null;
    selectedDevice !=null ? listenerPrintService.setChange(3, isConnect) : null;
  }
*/

  /* List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
        for (BluetoothDevice device in connectedDevices) {
          if (device.name == nameTargetDevice) {
            selectedDevice = device;
            disconnect(context);
            discoverServices(selectedDevice!);
            listenToDeviceState(context);
            notifyListeners();
            return;
          }
        }*/


  void scanForDevices(context) async {
    bool isBluetoothOn = await FlutterBluePlus.isOn;
    if (!isBluetoothOn) {
      showOverlay(context, const CustomToast(message: 'Encienda Bluethooth'));
      return;
    }
    bool deviceFound = false;

    try {
      listenerPrintService.setChange(0, null);
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5),

        withServices: [
          Guid("00001800-0000-1000-8000-00805f9b34fb"),
          //Guid("49535343-fe7d-4ae5-8fa9-9fafd205e455"),
          Guid("e7810a71-73ae-499d-8c15-faa9aef0c3f2"),
        ],);
      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.name == nameTargetDevice) {
            deviceFound = true;
            FlutterBluePlus.stopScan();
            selectedDevice = r.device;
            isConnect = true;
            print("Dispositivo encontrado: ${selectedDevice?.name}");
            try {
              await Future.delayed(const Duration(milliseconds: 50));
              await selectedDevice!.connect();
              discoverServices(selectedDevice!);
              List<BluetoothService> services = await selectedDevice!.discoverServices();
              services.forEach((service) {
                print('Service UUID: ${selectedDevice?.name} ${service.uuid}');
              });
              isConnect = true;
              listenToDeviceState(context);  // Inicia la escucha después de la conexión
              listenerPrintService.setChange(1, true);
              print("Dispositivo conectado: ${selectedDevice?.name}");
              showOverlay(context, const CustomToast(message: "Dispositivo conectado correctamente"));
              notifyListeners();
            } catch (e) {
              print("Error al conectar con el dispositivo: $e");
              selectedDevice = null;
              listenerPrintService.setChange(0, null);
              showOverlay(context, const CustomToast(message: "Espere mientras se reconecta automáticamente"));
              await Future.delayed(const Duration(seconds: 8));
              scanForDevices(context);
              notifyListeners();
            }
            break;
          }}
      });
      await Future.delayed(const Duration(seconds: 5));
      if (!deviceFound) {
        listenerPrintService.setChange(3, null);
        showOverlay(context, const CustomToast(message: "Dispositivo no encontrado"));
      }
    } catch (e) {
      print("Error durante el escaneo: $e");
    }

  }

  void listenToDeviceState(context) {
    _connectionSubscription?.cancel();
    final selectedDevice = this.selectedDevice;
    if (selectedDevice != null) {
      _connectionSubscription = selectedDevice.state.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          disconnect(context);
        }});}}

  void disconnect(context) async {
    if (selectedDevice != null ) {
      try {
        _connectionSubscription?.cancel();
        await selectedDevice?.disconnect();
        selectedDevice = null;
        isConnect = false;
        listenerPrintService.setChange(2, false);
        notifyListeners();
        showOverlay(context, const CustomToast(message: 'Dispositivo desconectado correctamente'));
      } catch (e) {
        print("Error al desconectar el dispositivo: $e");
      }
    }
  }
}