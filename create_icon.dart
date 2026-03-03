import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Leer el logo original
  final logoFile = File('assets/logo/logo_app_1.png');
  final logoBytes = await logoFile.readAsBytes();
  final logo = img.decodeImage(logoBytes);

  if (logo == null) {
    print('Error: No se pudo leer el logo');
    return;
  }

  print('Logo original: ${logo.width}x${logo.height}');

  // Crear un canvas cuadrado de 1024x1024 con fondo oscuro
  final size = 1024;
  final canvas = img.Image(width: size, height: size);

  // Llenar con color de fondo
  img.fill(canvas, color: img.ColorRgb8(255, 255, 255)); // BLANCO

  // Calcular el tamaño manteniendo el aspect ratio
  // El logo ocupará el 90% del canvas
  final maxSize = (size * 0.9).toInt();

  int newWidth, newHeight;
  if (logo.width > logo.height) {
    newWidth = maxSize;
    newHeight = (logo.height * maxSize / logo.width).toInt();
  } else {
    newHeight = maxSize;
    newWidth = (logo.width * maxSize / logo.height).toInt();
  }

  final resizedLogo = img.copyResize(
    logo,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.cubic,
  );

  // Centrar el logo
  final x = (size - resizedLogo.width) ~/ 2;
  final y = (size - resizedLogo.height) ~/ 2;

  // Componer el logo sobre el canvas
  img.compositeImage(canvas, resizedLogo, dstX: x, dstY: y);

  // Guardar el icono
  final iconFile = File('assets/logo/app_icon.png');
  await iconFile.writeAsBytes(img.encodePng(canvas));

  print('✓ Icono creado: ${size}x${size}');
  print('✓ Logo dentro: ${newWidth}x${newHeight}');
  print('✓ Guardado en: assets/logo/app_icon.png');
}
