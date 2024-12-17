import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'camera.dart';
import 'thresholding.dart';
import 'find_contours.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Morphometry',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CameraDescription camera;

  MyHomePage({required this.camera});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  img.Image? _binaryImage;
  List<List<img.Point>>? _contours;
  ui.Image? _uiImage;

  Future<void> _takePicture(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TakePictureScreen(camera: widget.camera)),
    );

    if (result != null) {
      setState(() {
        _image = File(result);
        _binaryImage = Thresholding.binarizeImage(_image!);
        _processImage();
      });
    }
  }

  void _processImage() async {
    if (_image != null) {
      // Бинаризация изображения
      _binaryImage = Thresholding.binarizeImage(_image!);
      // Поиск контуров на бинарном изображении
      if (_binaryImage != null) {
        _contours = FindContours.findContours(_binaryImage!);
        // Находим размеры объекта по контурам
        if (_contours != null && _contours!.isNotEmpty) {
          final boundingBox = FindContours.findBoundingBox(_contours![0]); // Используем первый контур
          FindContours.showAlertDialog(context, boundingBox.width, boundingBox.height);
        }
      }

      // Загружаем изображение для отрисовки
      final imageBytes = img.encodePng(_binaryImage!);
      _uiImage = await decodeImageFromList(imageBytes);

      setState(() {}); // Обновляем состояние
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Morphometry'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('Выберите изображение') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _takePicture(context),
              child: Text('Сделать снимок'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _processImage();
                  });
                }
              },
              child: Text('Выбрать из галереи'),
            ),
            SizedBox(height: 20),
            // Отображение бинарного изображения
            if (_uiImage != null)
              CustomPaint(
                size: Size(_binaryImage!.width.toDouble() - 150, _binaryImage!.height.toDouble() - 250),
                painter: ContoursPainter(_binaryImage!, _contours, _uiImage!),
              ),
          ],
        ),
      ),
    );
  }
}

class ContoursPainter extends CustomPainter {
  final img.Image binaryImage;
  final List<List<img.Point>>? contours;
  final ui.Image uiImage;

  ContoursPainter(this.binaryImage, this.contours, this.uiImage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.scale(size.width / binaryImage.width, size.height / binaryImage.height);

    // Отрисовка бинарного изображения
    canvas.drawImage(uiImage, Offset.zero, Paint());

    // Рисуем контуры
    if (contours != null) {
      for (final contour in contours!) {
        final path = Path();
        if (contour.isNotEmpty) {
          path.moveTo(contour[0].x.toDouble(), contour[0].y.toDouble());
          for (final point in contour) {
            path.lineTo(point.x.toDouble(), point.y.toDouble());
          }
          path.close();
          canvas.drawPath(path, paint); // Рисуем контур
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}