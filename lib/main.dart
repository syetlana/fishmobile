import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'camera.dart';
import 'thresholding.dart';
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

  Future<void> _takePicture(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TakePictureScreen(camera: widget.camera)),
    );

    if (result != null) {
      setState(() {
        _image = File(result);
        _binaryImage = Thresholding.binarizeImage(_image!); // Получение бинарного изображения
      });
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
                    _binaryImage = Thresholding.binarizeImage(_image!); // Получение бинарного изображения
                  });
                }
              },
              child: Text('Выбрать из галереи'),
            ),
            SizedBox(height: 20),
            // Отображение бинарного изображения
            if (_binaryImage != null)
              Image.memory(img.encodeJpg(_binaryImage!)), // Отображаем бинарное изображение
          ],
        ),
      ),
    );
  }
}