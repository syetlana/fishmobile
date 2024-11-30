import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class Thresholding {
  static img.Image binarizeImage(File imageFile) {
    // Загружаем изображение
    final image = img.decodeImage(imageFile.readAsBytesSync())!;

    // Параметры для пороговой обработки
    int threshold = 128; // Уровень порога, можно настраивать

    // Создаем новое бинарное изображение
    final binaryImage = img.Image(width: image.width, height: image.height);

    // Проходим по всем пикселям изображения
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        // Получаем цвет пикселя
        img.Pixel pixel = image.getPixel(x, y);
        // Получаем значение яркости
        num brightness = img.getLuminance(pixel);

        // Устанавливаем цвет в бинарное изображение
        if (brightness < threshold) {
          // Если яркость ниже порога, устанавливаем черный пиксель
          binaryImage.setPixel(x, y, img.convertColor(img.ColorRgb8(0, 0, 0)));
        } else {
          // Если яркость выше порога, устанавливаем белый пиксель
          binaryImage.setPixel(x, y, img.convertColor(img.ColorRgb8(255, 255, 255)));
        }
      }
    }

    return binaryImage;
  }
}
