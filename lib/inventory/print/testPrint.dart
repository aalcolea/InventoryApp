import 'dart:convert';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;

class testPrint extends StatefulWidget {
  @override
  _testPrintState createState() => _testPrintState();
}

class _testPrintState extends State<testPrint> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? selectedDevice;
  BluetoothCharacteristic? characteristic;
  String nameTargetDevice = 'MP210';

  void initState() {
    super.initState();
    connectToSpecificDevice();
  }

  Future<void> printImageBW(String imagePath, {int maxWidth = 260, int maxHeight = 95, int ajusteManual = 0}) async {
    if (characteristic == null) return;

    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage != null) {
      img.Image resizedImage = img.copyResize(originalImage, width: maxWidth);

      if (resizedImage.height > maxHeight) {
        resizedImage = img.copyResize(resizedImage, height: maxHeight);
      }

      int marginWidth = ((maxWidth - resizedImage.width) ~/ 2) + ajusteManual;
      img.Image centeredImage = img.Image(maxWidth, resizedImage.height);

      centeredImage.fill(img.getColor(255, 255, 255)); // Color blanco
      img.drawImage(centeredImage, resizedImage, dstX: marginWidth, dstY: 0);

      img.Image bwImage = _convertToBW(centeredImage);
      List<int> imageBytes = _convertImageToPrinterData(bwImage);

      const chunkSize = 600;
      for (int i = 0; i < imageBytes.length; i += chunkSize) {
        int end = (i + chunkSize < imageBytes.length) ? i + chunkSize : imageBytes.length;
        await characteristic!.write(Uint8List.fromList(imageBytes.sublist(i, end)), withoutResponse: false);
        Future.delayed(const Duration(milliseconds: 10));
      }

      await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: false);
      print('Imagen impresa en blanco y negro.');
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

  Future<void> printImageWithAtkinsonDithering(String imagePath, {int maxWidth = 384, int maxHeight = 200}) async {
    if (characteristic == null) return;

    ByteData data = await rootBundle.load(imagePath);
    Uint8List bytes = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      img.Image processedImage = applyAtkinsonDithering(image, maxWidth, maxHeight);

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      // Convertir la imagen procesada a un formato de impresión ESC/POS
      List<int> escPosData = generator.image(processedImage);

      // Enviar los datos a la impresora en bloques con un retraso entre cada bloque
      const chunkSize = 600; // Ajusta el tamaño de los bloques según sea necesario
      for (int i = 0; i < escPosData.length; i += chunkSize) {
        int end = (i + chunkSize < escPosData.length) ? i + chunkSize : escPosData.length;
        await characteristic!.write(Uint8List.fromList(escPosData.sublist(i, end)), withoutResponse: false);
        await Future.delayed(Duration(milliseconds: 50));//20-50//30-25//60-25//necesita el delay de 10 ms para imprimir ANDRIOD
      }

      // Añadir salto de línea final
      //await characteristic!.write(Uint8List.fromList(escPosData), withoutResponse: true);
      await characteristic!.write(Uint8List.fromList([0x0A]), withoutResponse: false);
    } else {
      print("Error al cargar la imagen");
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

  void connectToSpecificDevice() async {
    BluetoothDevice? targetDevice;
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == nameTargetDevice) {
          targetDevice = r.device;
          await FlutterBluePlus.stopScan();
          setState(() {
            selectedDevice = targetDevice;
          });
          await selectedDevice!.connect();
          discoverServices(selectedDevice!);
          break;
        }
      }
    });
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic charac in service.characteristics) {
        if (charac.properties.write) {
          setState(() {
            characteristic = charac;
          });
          break; // Termina después de encontrar una característica de escritura
        }
      }
    }
  }

  void sendMessage(String message) async {
    if (characteristic != null) {
      List<int> bytes = utf8.encode(message + "\n");
      await characteristic!.write(bytes, withoutResponse: false);
    }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Escoger impresora"),
      ),
      body: Column(
        children: [
          IconButton(onPressed: (){
            Navigator.of(context).pop();

          }, icon: Icon(Icons.ac_unit)),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () async {
                    setState(() {
                      selectedDevice = devicesList[index];
                    });
                    await selectedDevice!.connect();
                    discoverServices(selectedDevice!);
                  },
                );
              },
            ),
          ),
          if (selectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: "mensaje "),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      //printImageWithAtkinsonDithering('assets/imgLog/test2.jpeg');
                      printImageBW('assets/imgLog/test2.jpeg', ajusteManual: -36);
                    },
                    child: Text("Imprimir"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}