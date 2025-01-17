import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

class SalesPrintService {

  BluetoothCharacteristic? characteristic;
  SalesPrintService(this.characteristic);

  Future<void> centrar () async{// esta porque la impresion de androiod no centrar la imagen
    List<int> bytes = [];
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    await characteristic!.write(Uint8List.fromList(bytes), withoutResponse: false);
  }

  Future<void> connectAndPrintAndroide(List<Map<String, dynamic>> products, String imagePath, String saleDate) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }
    await centrar();
    await printImageBW(imagePath);
    await printText(products, saleDate);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> connectAndPrintIOS(List<Map<String, dynamic>> products, String imagePath, String saleDate) async {
    if (characteristic == null) {
      print("Error: No se encontró la característica para imprimir.");
      return;
    }

    await printImageWithAtkinsonDithering(imagePath, maxWidth: 200, maxHeight: 200);
    await printTextIos(products, saleDate);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> printText(List<Map<String, dynamic>> products, String saleDate) async {
    String lugar = 'Lugar exp: Conkal, Yucatan\n';
    double cuentaTotal = 0;

    if (characteristic == null) return;

    List<int> bytes = [];

    // Comando ESC/POS para centrar y poner en negrita el texto "BEUATE CLINIQUE"
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
    bytes += utf8.encode('MINISUPER SAN JUAN DIEGO\n\n');
    bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
    bytes += utf8.encode('\x1B\x61\x00'); // Alinear izquierda
    //bytes += utf8.encode('\x1B\x61\x02'); // Alinear der
    bytes += utf8.encode(lugar);
    Future.delayed(Duration(milliseconds: 25));
    bytes += utf8.encode('Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}\n');
    Future.delayed(Duration(milliseconds: 25));
    // Espacio adicional
    bytes += utf8.encode('\n');
    bytes += utf8.encode('Ventas del dia ${saleDate}\n');
    bytes += utf8.encode('\n');

    // Encabezados de la tabla//5
    bytes += utf8.encode('CANT |     PROD     |  IMPORTE\n');
    Future.delayed(const Duration(milliseconds: 25));
    bytes += utf8.encode('--------------------------------\n');

    for (var item in products) {
      String productName = item['nombre'];
      double productPrice = item['precio'];
      int productQuantity = item['cantidad'].toInt();
      double total = productPrice * productQuantity;
      cuentaTotal += total;
      List<String> partesProducto = [];

      int maxCaracteres = 14;
      for (int i = 0; i < productName.length; i += maxCaracteres) {
        int fin = (i + maxCaracteres < productName.length) ? i + maxCaracteres : productName.length;
        String parte = productName.substring(i, fin);
        partesProducto.add(parte.padRight(maxCaracteres));
        Future.delayed(const Duration(milliseconds: 25));
      }

      String formattedTotal = ('\$${total.toStringAsFixed(2)}').padLeft(10);
      String formattedCant = (productQuantity.toStringAsFixed(0)).padLeft(3);

      //esto es del precio individual de cada prod
      //String price = productPrice.toStringAsFixed(1);
      //String paddedPrice = price.padRight(6);

      for (int j = 0; j < partesProducto.length; j++) {
        if (j == 0) {
          bytes += utf8.encode('  $formattedCant ${partesProducto[j]}  $formattedTotal');
        } else if (j < 3) {
          bytes += utf8.encode('      ${partesProducto[j]}\n');
        } else {
          break;
        }
      }
      //bytes += utf8.encode('$productName: $productQuantity x \$${productPrice.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}\n');
    }

    int amountLength = cuentaTotal.toStringAsFixed(0).length;
    int lineWidth = 16 - (amountLength - 10).clamp(0, 19);

    String totalText = 'TOTAL';
    String amountText = '\$${cuentaTotal.toStringAsFixed(2)}';


    bytes += utf8.encode('--------------------------------\n');
    Future.delayed(const Duration(milliseconds: 25));
    int totalLength = totalText.length + amountText.length;
    int spacesToAdd = lineWidth - totalLength;
    String padding = ' ' * spacesToAdd.clamp(0, lineWidth);
    bytes += utf8.encode('\x1D\x21\x11');
    bytes += utf8.encode('$totalText$padding$amountText\n');
    bytes += utf8.encode('\x1D\x21\x00');
    bytes += utf8.encode('--------------------------------\n');
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON

    bytes += utf8.encode('\x1D\x21\x00');
    bytes += utf8.encode('--------------------------------\n');
    bytes += utf8.encode('\x1B\x61\x01');// Negrita OFF
    bytes += utf8.encode('\n\n\n');

    const int chunkSize = 245;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;
      await characteristic!.write(Uint8List.fromList(bytes.sublist(i, end)), withoutResponse: false);
    }

    //await characteristic!.write(Uint8List.fromList(bytes), withoutResponse: false);
    await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: false);
  }

  Future<void> printTextIos(List<Map<String, dynamic>> products, String saleDate) async {
    String lugar = 'Lugar exp: Conkal, Yucatan\n';
    double cuentaTotal = 0;

    if (characteristic == null) return;

    List<int> bytes = [];

    // Comando ESC/POS para centrar y poner en negrita el texto "BEUATE CLINIQUE"
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON
    bytes += utf8.encode('MINISUPER SAN JUAN DIEGO\n\n');
    bytes += utf8.encode('\x1B\x45\x00'); // Negrita OFF
    bytes += utf8.encode('\x1B\x61\x00'); // Alinear izquierda
    //bytes += utf8.encode('\x1B\x61\x02'); // Alinear der
    bytes += utf8.encode(lugar);
    Future.delayed(Duration(milliseconds: 25));
    bytes += utf8.encode('Fecha exp: ${DateFormat.yMd().format(DateTime.now())} ${DateFormat.jm().format(DateTime.now())}\n');
    Future.delayed(Duration(milliseconds: 25));
    // Espacio adicional
    bytes += utf8.encode('\n');
    bytes += utf8.encode('Ventas del dia ${saleDate}\n');
    bytes += utf8.encode('\n');

    // Encabezados de la tabla//5
    bytes += utf8.encode('CANT |     PROD     |  IMPORTE\n');
    Future.delayed(const Duration(milliseconds: 25));
    bytes += utf8.encode('--------------------------------\n');

    for (var item in products) {
      String productName = item['nombre'];
      double productPrice = item['precio'];
      int productQuantity = item['cantidad'].toInt();
      double total = productPrice * productQuantity;
      cuentaTotal += total;
      List<String> partesProducto = [];

      int maxCaracteres = 14;
      for (int i = 0; i < productName.length; i += maxCaracteres) {
        int fin = (i + maxCaracteres < productName.length) ? i + maxCaracteres : productName.length;
        String parte = productName.substring(i, fin);
        partesProducto.add(parte.padRight(maxCaracteres));
        Future.delayed(const Duration(milliseconds: 25));
      }

      String formattedTotal = ('\$${total.toStringAsFixed(2)}').padLeft(10);
      String formattedCant = (productQuantity.toStringAsFixed(0)).padLeft(3);

      //esto es del precio individual de cada prod
      //String price = productPrice.toStringAsFixed(1);
      //String paddedPrice = price.padRight(6);

      for (int j = 0; j < partesProducto.length; j++) {
        if (j == 0) {
          bytes += utf8.encode('  $formattedCant ${partesProducto[j]}  $formattedTotal');
        } else if (j < 3) {
          bytes += utf8.encode('      ${partesProducto[j]}\n');
        } else {
          break;
        }
      }
      //bytes += utf8.encode('$productName: $productQuantity x \$${productPrice.toStringAsFixed(2)} = \$${total.toStringAsFixed(2)}\n');
    }

    int amountLength = cuentaTotal.toStringAsFixed(0).length;
    int lineWidth = 16 - (amountLength - 10).clamp(0, 19);

    String totalText = 'TOTAL';
    String amountText = '\$${cuentaTotal.toStringAsFixed(2)}';


    bytes += utf8.encode('--------------------------------\n');
    Future.delayed(const Duration(milliseconds: 25));
    int totalLength = totalText.length + amountText.length;
    int spacesToAdd = lineWidth - totalLength;
    String padding = ' ' * spacesToAdd.clamp(0, lineWidth);
    bytes += utf8.encode('\x1D\x21\x11');
    bytes += utf8.encode('$totalText$padding$amountText\n');
    bytes += utf8.encode('\x1D\x21\x00');
    bytes += utf8.encode('--------------------------------\n');
    bytes += utf8.encode('\x1B\x61\x01'); // Alinear centro
    bytes += utf8.encode('\x1B\x45\x01'); // Negrita ON

    bytes += utf8.encode('\x1D\x21\x00');
    bytes += utf8.encode('--------------------------------\n');
    bytes += utf8.encode('\x1B\x61\x01');// Negrita OFF
    bytes += utf8.encode('\n\n\n');

    const int chunkSize = 178;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;
      await characteristic!.write(Uint8List.fromList(bytes.sublist(i, end)), withoutResponse: false);
    }

    //await characteristic!.write(Uint8List.fromList(bytes), withoutResponse: false);
    await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: false);
  }

  //funcion para imprimir imagen android
  Future<void> printImageBW(String imagePath, {int maxWidth = 260, int maxHeight = 75}) async {
    if (characteristic == null) return;

    print('Inicio de conversión de imagen para impresión en blanco y negro');

    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      img.Image resizedImage = img.copyResize(originalImage, width: maxWidth);

      if (resizedImage.height > maxHeight) {
        resizedImage = img.copyResize(resizedImage, height: maxHeight);
      }
      img.Image bwImage = _convertToBW(resizedImage);
      List<int> imageBytes = _convertImageToPrinterData(bwImage);

      //const chunkSize = 600;
      const chunkSize = 245;
      for (int i = 0; i < imageBytes.length; i += chunkSize) {
        int end = (i + chunkSize < imageBytes.length) ? i + chunkSize : imageBytes.length;
        await characteristic!.write(Uint8List.fromList(imageBytes.sublist(i, end)), withoutResponse: false);
        Future.delayed(const Duration(milliseconds: 10));
      }
      await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: false);
    } else {
      print("Error al cargar la imagen.");
    }
  }

  img.Image _convertToBW(img.Image image,  {int luminanceThreshold = 200}) {
    img.Image bwImage = img.Image(image.width, image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int luminance = img.getLuminance(pixel);
        bwImage.setPixel(x, y, luminance < luminanceThreshold  ? img.getColor(0, 0, 0) : img.getColor(255, 255, 255));
      }
    }
    return bwImage;
  }

  List<int> _convertImageToPrinterData(img.Image image) {

    List<int> bytes = [];
    bytes.addAll([0x1B, 0x33, 0x00]);
    for (int y = 0; y < image.height; y += 8) {
      bytes.addAll([0x1B, 0x2A, 0x00, image.width & 0xFF, (image.width >> 8) & 0xFF]);

      for (int x = 0; x < image.width; x++) {
        int byte = 0;
        for (int b = 0; b < 8; b++) {
          int pixelY = y + b;
          if (pixelY < image.height) {
            int color = image.getPixel(x, pixelY);
            if (color == img.getColor(0, 0, 0)) {
              byte |= (1 << (7 - b));
            }
          }
        }
        bytes.add(byte);
      }
      bytes.add(0x0A);
    }
    bytes.addAll([0x1B, 0x32]);

    return bytes;
  }
  //termina funcion para android

  Future<void> printImageWithAtkinsonDithering(String imagePath, {int maxWidth = 384, int maxHeight = 200, int chunkSize = 182}) async {
    if (characteristic == null) return;

    try {
      // Cargar la imagen desde el archivo
      ByteData data = await rootBundle.load(imagePath);
      Uint8List bytes = data.buffer.asUint8List();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        print("Error al cargar la imagen");
        return;
      }

      img.Image processedImage = applyAtkinsonDithering(image, maxWidth, maxHeight);

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> escPosData = generator.image(processedImage);

      for (int i = 0; i < escPosData.length; i += chunkSize) {
        int end = (i + chunkSize < escPosData.length) ? i + chunkSize : escPosData.length;
        List<int> chunk = escPosData.sublist(i, end);
        await characteristic!.write(Uint8List.fromList(chunk), withoutResponse: true);
      }

      await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: true);

    } catch (e) {
      print("Error al intentar imprimir: $e");
    }
  }

  img.Image applyAtkinsonDithering(img.Image image, int maxWidth, int maxHeight) {
    int width = image.width;
    int height = image.height;
    double scale = (width / height > maxWidth / maxHeight)
        ? maxWidth / width
        : maxHeight / height;
    img.Image resizedImage = img.copyResize(image, width: (width * scale).toInt(), height: (height * scale).toInt(), interpolation: img.Interpolation.cubic);
    img.Image finalImage = img.Image(maxWidth, maxHeight);
    img.fill(finalImage, img.getColor(255, 255, 255));
    img.drawImage(finalImage, resizedImage, dstX: (maxWidth - resizedImage.width) ~/ 2, dstY: (maxHeight - resizedImage.height) ~/ 2);

    for (int y = 0; y < finalImage.height; y++) {
      for (int x = 0; x < finalImage.width; x++) {
        int oldPixel = img.getLuminance(finalImage.getPixel(x, y));
        int newPixel = oldPixel < 128 ? 0 : 255;
        int error = oldPixel - newPixel;
        finalImage.setPixel(x, y, newPixel == 0 ? img.getColor(0, 0, 0) : img.getColor(255, 255, 255));
        if (x + 1 < finalImage.width) applyError(finalImage, x + 1, y, error >> 3);
        if (x + 2 < finalImage.width) applyError(finalImage, x + 2, y, error >> 3);
        if (y + 1 < finalImage.height) {
          if (x - 1 >= 0) applyError(finalImage, x - 1, y + 1, error >> 3);
          applyError(finalImage, x, y + 1, error >> 3);
          if (x + 1 < finalImage.width) applyError(finalImage, x + 1, y + 1, error >> 3);
        }
        if (y + 2 < finalImage.height) {
          applyError(finalImage, x, y + 2, error >> 3);
        }
      }
    }
    return finalImage;
  }

  void applyError(img.Image image, int x, int y, int error) {
    int pixel = img.getLuminance(image.getPixel(x, y));
    int newPixel = (pixel + error).clamp(0, 255).toInt();
    image.setPixel(x, y, img.getColor(newPixel, newPixel, newPixel));
  }
}