import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  TakePictureScreen({required this.camera});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final String stencilPath = 'assets/fish_icon_1.png';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place the fish inside the template'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(
                  child: Container(
                    width: 400,
                    height: 550,
                    child: CameraPreview(_controller),
                  ),
                ),
                Center(
                  child: Image.asset(
                    stencilPath,
                    width: 400,
                    height: 600,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            final croppedImage = await _cropImage(image.path);

            // Возврат пути к обрезанному изображению на главный экран
            Navigator.pop(context, croppedImage.path);
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  Future<File> _cropImage(String imagePath) async {
    // Загружаем изображение
    final image = img.decodeImage(File(imagePath).readAsBytesSync())!;

    // Обрезаем сверху и снизу
    final croppedImage = img.copyCrop(
      image,
      x: 0, // координата X
      y: 400, // координата Y
      width: image.width, // ширина
      height: image.height - 800, // высота (убираем пиксели сверху и снизу)
    );

    // Сохраняем обрезанное изображение
    final croppedFile = File(imagePath)..writeAsBytesSync(img.encodeJpg(croppedImage));
    return croppedFile;
  }
}