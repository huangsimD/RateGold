import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Builds Play Store icon assets from brand tokens (#1B4332 / #C9A227).
/// Run: dart run tool/prepare_store_assets.dart
void main() {
  final playDir = Directory('${Directory.current.path}/store/play');
  playDir.createSync(recursive: true);

  final icon1024 = _buildIcon(1024);
  File('${playDir.path}/icon-1024.png')
      .writeAsBytesSync(img.encodePng(icon1024));

  final icon512 = img.copyResize(icon1024, width: 512, height: 512);
  File('${playDir.path}/icon-512.png')
      .writeAsBytesSync(img.encodePng(icon512));

  stdout.writeln('Wrote store/play/icon-1024.png (1024x1024)');
  stdout.writeln('Wrote store/play/icon-512.png (512x512)');
}

img.Image _buildIcon(int size) {
  final bg = img.ColorRgb8(0x1B, 0x43, 0x32);
  final line = img.ColorRgb8(0xFF, 0xFF, 0xFF);
  final gold = img.ColorRgb8(0xC9, 0xA2, 0x27);

  final canvas = img.Image(width: size, height: size);
  img.fill(canvas, color: bg);

  final inset = size * 0.14;
  final left = inset;
  final right = size - inset;
  final bottom = size - inset * 1.05;
  final top = inset * 1.15;

  final p1 = (x: left, y: bottom);
  final p2 = (x: left + (right - left) * 0.38, y: top + (bottom - top) * 0.42);
  final p3 = (x: left + (right - left) * 0.58, y: top + (bottom - top) * 0.62);
  final p4 = (x: right, y: top);

  final stroke = (size * 0.055).clamp(18.0, 72.0);
  _strokeSegment(canvas, p1.x, p1.y, p2.x, p2.y, stroke, line);
  _strokeSegment(canvas, p2.x, p2.y, p3.x, p3.y, stroke, line);
  _strokeSegment(canvas, p3.x, p3.y, p4.x, p4.y, stroke, line);

  final dotRadius = stroke * 0.72;
  img.fillCircle(
    canvas,
    x: p4.x.round(),
    y: p4.y.round(),
    radius: dotRadius.round(),
    color: gold,
  );

  return canvas;
}

void _strokeSegment(
  img.Image canvas,
  double x1,
  double y1,
  double x2,
  double y2,
  double width,
  img.Color color,
) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final length = math.sqrt(dx * dx + dy * dy);
  if (length == 0) return;

  final steps = (length * 2).round().clamp(40, 400);
  final nx = -dy / length;
  final ny = dx / length;
  final half = width / 2;

  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final cx = x1 + dx * t;
    final cy = y1 + dy * t;
    img.fillCircle(
      canvas,
      x: cx.round(),
      y: cy.round(),
      radius: half.round(),
      color: color,
    );
  }
}

/// Center-crops any PNG to square (utility for fixing AI exports).
img.Image centerSquare(img.Image source) {
  if (source.width == source.height) return source;
  final size = math.min(source.width, source.height);
  final x = (source.width - size) ~/ 2;
  final y = (source.height - size) ~/ 2;
  return img.copyCrop(source, x: x, y: y, width: size, height: size);
}
