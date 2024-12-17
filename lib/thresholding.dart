import 'dart:io';
import 'package:image/image.dart' as img;

class Thresholding {
  /// Метод для адаптивной бинаризации изображения
  static img.Image binarizeImage(File imageFile, {int blockSize = 15, int offset = 10}) {
    // Загружаем изображение из файла
    final originalImage = img.decodeImage(imageFile.readAsBytesSync());

    if (originalImage == null) {
      throw Exception("Не удалось загрузить изображение.");
    }

    // Преобразуем изображение в оттенки серого
    final grayscaleImage = img.grayscale(originalImage);
    final binaryImage = img.Image(width: grayscaleImage.width, height: grayscaleImage.height);

    for (int y = 0; y < grayscaleImage.height; y++) {
      for (int x = 0; x < grayscaleImage.width; x++) {
        // Вычисление границ блока
        int xStart = (x - blockSize ~/ 2).clamp(0, grayscaleImage.width - 1);
        int yStart = (y - blockSize ~/ 2).clamp(0, grayscaleImage.height - 1);
        int xEnd = (x + blockSize ~/ 2).clamp(0, grayscaleImage.width - 1);
        int yEnd = (y + blockSize ~/ 2).clamp(0, grayscaleImage.height - 1);

        // Вычисляем среднее значение яркости в блоке
        int sum = 0;
        int count = 0;
        for (int blockY = yStart; blockY <= yEnd; blockY++) {
          for (int blockX = xStart; blockX <= xEnd; blockX++) {
            final pixel = grayscaleImage.getPixel(blockX, blockY);
            sum += img.getLuminance(pixel).toInt();
            count++;
          }
        }
        final meanBrightness = sum ~/ count;

        // Бинаризация пикселя на основе локального среднего
        final pixel = grayscaleImage.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        final color = brightness < (meanBrightness - offset) ? img.convertColor(img.ColorRgb8(0, 0, 0)) : img.convertColor(img.ColorRgb8(255, 255, 255));
        binaryImage.setPixel(x, y, color);
      }
    }

    return binaryImage;
  }
}