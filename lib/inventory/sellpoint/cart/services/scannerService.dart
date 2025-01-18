import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class BarcodeScannerService {
  static final BarcodeScannerService _instance = BarcodeScannerService._internal();
  factory BarcodeScannerService() => _instance;
  BarcodeScannerService._internal();

  FocusNode focusNode = FocusNode();
  String barcodeBuffer = '';
  Timer? bufferClearTimer;
  Function(String)? onBarcodeScanned;
  BuildContext? _context;

  void initialize(BuildContext context, Function(String) onScanned) {
    _context = context;
    onBarcodeScanned = onScanned;
  }

  void dispose() {
    if (focusNode.hasPrimaryFocus) {
      focusNode.unfocus();
    }
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
    print('barcode $barcode');
    return _normalizeBarcode(barcode);
  }
}