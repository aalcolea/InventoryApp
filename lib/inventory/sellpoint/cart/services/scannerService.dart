import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class _ActivityLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  _ActivityLifecycleObserver({
    required this.onResume,
    required this.onPause,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      default:
        break;
    }
  }
}

class BarcodeScannerService {
  static final BarcodeScannerService _instance = BarcodeScannerService._internal();
  factory BarcodeScannerService() => _instance;
  BarcodeScannerService._internal();

  FocusNode focusNode = FocusNode();
  String barcodeBuffer = '';
  Timer? bufferClearTimer;
  Function(String)? onBarcodeScanned;
  BuildContext? _context;
  bool isReconnecting = false;

  final reconnectionController = StreamController<void>.broadcast();
  _ActivityLifecycleObserver? _lifecycleObserver;

  void initialize(BuildContext context, Function(String) onScanned) {
    _context = context;
    onBarcodeScanned = onScanned;

    if (Platform.isAndroid) {
      // Escuchar eventos de lifecycle de la app
      _lifecycleObserver  = _ActivityLifecycleObserver(
          onResume: () {
            // Dar tiempo al sistema para estabilizarse
            Future.delayed(Duration(milliseconds: 500), () {
              if (!focusNode.hasFocus && focusNode.canRequestFocus) {
                focusNode.requestFocus();
              }
            });
          },
          onPause: () {
            // Prevenir la pérdida de focus
            if (focusNode.hasFocus) {
              focusNode.canRequestFocus;
            }
          },);
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);

      SystemChannels.platform.setMethodCallHandler((MethodCall call) async {
        if (call.method == "SystemNavigator.pop") {
          return true;
        }
        return null;
      });
    }
  }

  void dispose() {
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
    }    reconnectionController.close();
    reconnectionController.close();
    if (focusNode.hasPrimaryFocus) {
      focusNode.unfocus();
    }
    focusNode.dispose();
    bufferClearTimer?.cancel();
    onBarcodeScanned = null;
    _context = null;
  }

  List<String> _normalizeBarcode(String barcode) {
    final variants = <String>{};
    variants.add(barcode);
    if (!barcode.startsWith('0')) {
      variants.add('0$barcode');
    }
    if (barcode.startsWith('0')) {
      variants.add(barcode.substring(1));
    }

    return variants.toList();
  }

  void handleKeyEvent(RawKeyEvent event) {
    try{
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (barcodeBuffer.isNotEmpty) {
            final variants = _normalizeBarcode(barcodeBuffer);
            onBarcodeScanned?.call(variants.first);
            barcodeBuffer = '';
          }
        } else {
          if (event.character != null && event.character!.isNotEmpty) {
            barcodeBuffer += event.character!;
            bufferClearTimer?.cancel();
            bufferClearTimer = Timer(const Duration(milliseconds: 200), () {
              barcodeBuffer = '';
            });
          }
        }
      }
    }catch (e) {
      debugPrint("Error al manejar el evento del teclado: $e");
    }
  }

  Widget wrapWithKeyboardListener(Widget child) {
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: handleKeyEvent,
      child: child,
    );
  }

  List<String> getBarcodeVariants(String barcode) {
    return _normalizeBarcode(barcode);
  }
}