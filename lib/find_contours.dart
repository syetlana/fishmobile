import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class FindContours {
  /// Метод для поиска контуров на бинарном изображении
  static List<List<img.Point>> findContours(img.Image binaryImage) {
    final contours = <List<img.Point>>[];
    final visited = List.generate(
      binaryImage.height,
          (_) => List<bool>.filled(binaryImage.width, false),
    );
    // Проход по каждому пикселю изображения
    for (int y = 0; y < binaryImage.height; y++) {
      for (int x = 0; x < binaryImage.width; x++) {
        final pixelColor = binaryImage.getPixel(x, y);
        final blackColor = img.ColorRgb8(0, 0, 0);
        // Если пиксель черный и не посещен, начинаем поиск контура
        if ((pixelColor.r == blackColor.r && pixelColor.g == blackColor.g && pixelColor.b == blackColor.b) && visited[y][x] == false) {
          final contour = _traceContour(binaryImage, x, y, visited);
          contours.add(contour);
        }
      }
    }
    print("Найдено contours: ${contours.length}");
    return contours;
  }

  /// Метод для трассировки одного контура
  static List<img.Point> _traceContour(
      img.Image binaryImage,
      int startX,
      int startY,
      List<List<bool>> visited,
      ) {
    final contour = <img.Point>[];
    final directions = [
      img.Point(0, -1),  // Вверх
      img.Point(1, 0),   // Вправо
      img.Point(0, 1),   // Вниз
      img.Point(-1, 0),  // Влево
    ];
    int x = startX;
    int y = startY;

    do {
      visited[y][x] = true;
      contour.add(img.Point(x, y));
      // Ищем следующий пиксель в контуре
      bool foundNext = false;
      for (final dir in directions) {
        final newX = x + dir.x;
        final newY = y + dir.y;
        final pixelColor = binaryImage.getPixel(newX.toInt(), newY.toInt());
        final blackColor = img.ColorRgb8(0, 0, 0);
        // Проверяем границы и пиксель
        if (newX >= 0 &&
            newX < binaryImage.width &&
            newY >= 0 &&
            newY < binaryImage.height &&
            !visited[newY.toInt()][newX.toInt()] &&
            (pixelColor.r == blackColor.r && pixelColor.g == blackColor.g && pixelColor.b == blackColor.b)) {
          x = newX.toInt();
          y = newY.toInt();
          foundNext = true;
          break;
        }
      }

      if (foundNext == false) break; // Если не нашли следующую точку, выходим
    } while (x != startX || y != startY);

    return contour;
  }

  /// Метод для нахождения размеров объекта по контуру
  static Rect findBoundingBox(List<img.Point> contour) {
    if (contour.isEmpty) {
      return const Rect.fromLTRB(0, 0, 0, 0); // Возвращаем пустой прямоугольник, если контур пуст.
    }

    num minX = contour[0].x;
    num maxX = contour[0].x;
    num minY = contour[0].y;
    num maxY = contour[0].y;

    // Проходим по всем точкам контура и находим границы
    for (var point in contour) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }

    // Создаем прямоугольник, представляющий размеры объекта
    return Rect.fromLTRB(minX.toDouble(), minY.toDouble(), maxX.toDouble(), maxY.toDouble());
  }

  /// Метод для отображения окна оповещения
  static void showAlertDialog(BuildContext context, double width, double height) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Размеры объекта'),
          content: Text('Ширина: $width, Высота: $height'),
          actions: [
            TextButton(
              child: Text('Ок'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрываем диалог
              },
            ),
          ],
        );
      },
    );
  }
}