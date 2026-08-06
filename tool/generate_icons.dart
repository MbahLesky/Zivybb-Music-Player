// Regenerates the Android launcher icons from the brand artwork in
// assets/images/.
//
//     flutter test tool/generate_icons.dart
//
// Replaces tools/zivybb_logo.py, which drew the old mark from Bezier
// geometry and needed Python, NumPy, and Pillow — none of which survive on
// this machine. The mark is now authored artwork rather than code, so this
// only has to rescale it, which dart:ui does on its own: no new dependency,
// and it runs anywhere Flutter does.
//
// It is a test file purely because `flutter test` is the shortest route to a
// working rasterizer. It asserts nothing about the app.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flattened icons for launchers predating adaptive icons, in px.
const _legacyDensities = {
  'mdpi': 48,
  'hdpi': 72,
  'xhdpi': 96,
  'xxhdpi': 144,
  'xxxhdpi': 192,
};

/// Adaptive layers are 108dp regardless of the mask the launcher applies.
const _adaptiveDensities = {
  'mdpi': 108,
  'hdpi': 162,
  'xhdpi': 216,
  'xxhdpi': 324,
  'xxxhdpi': 432,
};

/// Only the inner 72dp of the 108dp layer is guaranteed visible — everything
/// outside is fair game for the launcher's mask to crop.
const _safeZone = 72 / 108;

/// How much of that safe zone the mark fills. Chosen to reproduce the
/// proportions of the authored tile: after masking, the adaptive icon should
/// look like assets/images/zivybb_icon.png, not a shrunken version of it.
const _markFillsSafeZone = 0.65;

Future<ui.Image> _decode(String path) async {
  final bytes = await File(path).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

Future<void> _writePng(ui.Image image, String path) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List(), flush: true);
}

/// Rasterizes [paint] onto a transparent [size]x[size] canvas.
Future<ui.Image> _render(int size, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  paint(canvas);
  return recorder.endRecording().toImage(size, size);
}

/// Tight bounds of everything meaningfully opaque, in source pixels.
({int left, int top, int right, int bottom}) _opaqueBounds(
  ByteData rgba,
  int width,
  int height,
) {
  var left = width, top = height, right = -1, bottom = -1;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (rgba.getUint8(((y * width) + x) * 4 + 3) <= 8) continue;
      if (x < left) left = x;
      if (x > right) right = x;
      if (y < top) top = y;
      if (y > bottom) bottom = y;
    }
  }
  return (left: left, top: top, right: right, bottom: bottom);
}

String _hex(ByteData rgba, int width, int x, int y) {
  final i = ((y * width) + x) * 4;
  final value =
      (rgba.getUint8(i) << 16) |
      (rgba.getUint8(i + 1) << 8) |
      rgba.getUint8(i + 2);
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()} '
      '(a=${rgba.getUint8(i + 3)})';
}

void main() {
  testWidgets('regenerate launcher icons', (tester) async {
    // The engine's decode and toImage futures only complete on the real event
    // loop; the test binding's fake async would deadlock on them.
    await tester.runAsync(() async {
      final root = Directory.current.path;
      final images = '$root/assets/images';
      final res = '$root/android/app/src/main/res';

      final tile = await _decode('$images/zivybb_icon.png');
      final mark = await _decode('$images/zivybb_logo.png');
      stdout.writeln('tile ${tile.width}x${tile.height}  '
          'mark ${mark.width}x${mark.height}');

      // --- measurements, so the hand-written XML can match the artwork ---
      final tileRgba = (await tile.toByteData())!;
      final markRgba = (await mark.toByteData())!;

      final markBox = _opaqueBounds(markRgba, mark.width, mark.height);
      stdout.writeln(
        'mark bbox  x ${markBox.left}..${markBox.right}  '
        'y ${markBox.top}..${markBox.bottom}',
      );

      // Corner radius, read off the top edge: the first opaque pixel in row 0
      // sits exactly one radius in from the corner.
      var radius = 0;
      while (radius < tile.width &&
          tileRgba.getUint8(radius * 4 + 3) <= 128) {
        radius++;
      }
      stdout.writeln(
        'tile corner radius ~${radius}px '
        '(${(radius / tile.width * 100).toStringAsFixed(1)}% of the side)',
      );

      // Backdrop gradient, sampled down a column clear of the mark.
      for (final y in [4, 128, 256, 384, 507]) {
        stdout.writeln('backdrop y=$y  ${_hex(tileRgba, tile.width, 478, y)}');
      }
      stdout.writeln('backdrop left  ${_hex(tileRgba, tile.width, 6, 256)}');
      stdout.writeln('backdrop right ${_hex(tileRgba, tile.width, 505, 256)}');

      // --- legacy icons: the authored tile, straight down ---
      final tileSrc = Rect.fromLTWH(
        0,
        0,
        tile.width.toDouble(),
        tile.height.toDouble(),
      );
      for (final entry in _legacyDensities.entries) {
        final size = entry.value;
        final image = await _render(size, (canvas) {
          canvas.drawImageRect(
            tile,
            tileSrc,
            Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
            Paint()..filterQuality = FilterQuality.high,
          );
        });
        await _writePng(image, '$res/mipmap-${entry.key}/ic_launcher.png');
      }
      stdout.writeln('wrote mipmap-*/ic_launcher.png');

      // --- adaptive foreground: the bare mark, centred in the safe zone ---
      final markSrc = Rect.fromLTRB(
        markBox.left.toDouble(),
        markBox.top.toDouble(),
        markBox.right + 1,
        markBox.bottom + 1,
      );
      for (final entry in _adaptiveDensities.entries) {
        final size = entry.value.toDouble();
        final target = size * _safeZone * _markFillsSafeZone;
        // Scale the longer side to the target so the mark never overflows the
        // safe zone, and keep its aspect ratio.
        final scale = target / math_max(markSrc.width, markSrc.height);
        final width = markSrc.width * scale;
        final height = markSrc.height * scale;
        final image = await _render(entry.value, (canvas) {
          canvas.drawImageRect(
            mark,
            markSrc,
            Rect.fromLTWH(
              (size - width) / 2,
              (size - height) / 2,
              width,
              height,
            ),
            Paint()..filterQuality = FilterQuality.high,
          );
        });
        await _writePng(
          image,
          '$res/mipmap-${entry.key}/ic_launcher_foreground.png',
        );
      }
      stdout.writeln('wrote mipmap-*/ic_launcher_foreground.png');
    });
  });
}

double math_max(double a, double b) => a > b ? a : b;
