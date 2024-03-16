import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CropArea());
  }
}

class CropArea extends StatefulWidget {
  const CropArea({super.key});

  @override
  CropAreaState createState() => CropAreaState();
}

class CropAreaState extends State<CropArea> {
  Rect? cropRect;
  final GlobalKey _globalKey = GlobalKey();

  Future<ui.Image> takeScreenshot() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    //ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return image;
    //Uint8List pngBytes = byteData!.buffer.asUint8List();
    // Şimdi pngBytes, ekran görüntüsünün PNG formatında bir temsilidir.
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        key: _globalKey,
        child: GestureDetector(
          onPanStart: (details) {
            setState(() {
              cropRect = Rect.fromPoints(
                  details.globalPosition, details.globalPosition);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              cropRect =
                  Rect.fromPoints(cropRect!.topLeft, details.globalPosition);
            });
          },
          onPanEnd: (details) async {
            if (kDebugMode) {
              if (cropRect == null) return;
              ui.Image image = await takeScreenshot();
              final kirpilmisSoru = await cropImage(image, cropRect!);
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: RawImage(
                          image: kirpilmisSoru,
                        ),
                      ));
              print('Kırpma alanı: $cropRect');
            }
          },
          child: CustomPaint(
              painter: CropPainter(cropRect),
              child: Column(
                children: [
                  Container(color: Colors.red,width: 200,height: 400,),
                  Container(color: Colors.green,width: 300,height: 200,),
                ],
              )),
        ));
  }

  Future<ui.Image> cropImage(ui.Image image, Rect cropRect) async {
    // Kırpma alanının boyutlarına sahip yeni bir resim oluşturun
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(
        pictureRecorder, Rect.fromLTWH(0, 0, cropRect.width, cropRect.height));

    // Kırpma alanını çiz
    canvas.drawImageRect(image, cropRect,
        Rect.fromLTWH(0, 0, cropRect.width, cropRect.height), Paint());

    // Resmi oluştur
    final picture = pictureRecorder.endRecording();
    final croppedImage =
        await picture.toImage(cropRect.width.toInt(), cropRect.height.toInt());

    return croppedImage;
  }
}

class CropPainter extends CustomPainter {
  final Rect? cropRect;

  CropPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (cropRect != null) {
      canvas.drawRect(cropRect!, paint);
    }
  }

  @override
  bool shouldRepaint(CropPainter oldDelegate) => true;
}
