import 'dart:io';
import 'package:image/image.dart' as img;
void main() {
  final imageBytes = File('assets/images/logo.png').readAsBytesSync();
  final image = img.decodeImage(imageBytes)!;
  final cropSize = (image.width * 0.7).toInt(); // Crop to 70% of the center to make it bigger
  final offset = (image.width * 0.15).toInt(); // Start at 15% to center it
  final cropped = img.copyCrop(image, x: offset, y: offset, width: cropSize, height: cropSize);
  File('assets/images/logo.png').writeAsBytesSync(img.encodePng(cropped));
}
