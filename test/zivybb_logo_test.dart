import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/shared/widgets/zivybb_logo.dart';

const _size = 256.0;
final _boundaryKey = GlobalKey();

/// Pumps the logo and reads back its pixels.
Future<Uint8List> _pixelsOf(WidgetTester tester) async {
  await tester.pumpWidget(
    Center(
      child: RepaintBoundary(
        key: _boundaryKey,
        child: const ZivybbLogo(size: _size),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Rasterizing has to happen on the real event loop: the test binding's
  // fake async never completes the engine's image futures, so calling
  // toImage() outside runAsync just deadlocks.
  late Uint8List pixels;
  await tester.runAsync(() async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    pixels = data!.buffer.asUint8List();
  });
  return pixels;
}

int _alphaAt(Uint8List pixels, int x, int y) =>
    pixels[((y * _size.toInt()) + x) * 4 + 3];

void main() {
  testWidgets('paints a mark that sits centred inside its box', (tester) async {
    final pixels = await _pixelsOf(tester);

    var painted = 0;
    var minX = _size.toInt(), maxX = 0, minY = _size.toInt(), maxY = 0;
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        if (_alphaAt(pixels, x, y) <= 8) continue;
        painted++;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }

    expect(painted, greaterThan(0), reason: 'the mark should paint something');
    // Roughly a fifth of the box is ink. A wildly different figure means the
    // stroke widths or the weave knockouts have gone wrong.
    expect(painted / (_size * _size), inInclusiveRange(0.05, 0.35));

    // The geometry is centred in a 512 design space with ~105px margins, so
    // every edge should be inset by about a fifth of the box.
    expect(minX / _size, inInclusiveRange(0.14, 0.26));
    expect(1 - maxX / _size, inInclusiveRange(0.14, 0.26));
    expect(minY / _size, inInclusiveRange(0.14, 0.26));
    expect(1 - maxY / _size, inInclusiveRange(0.14, 0.26));
  });

  testWidgets('the weave punches transparent gaps where strokes cross', (
    tester,
  ) async {
    final pixels = await _pixelsOf(tester);

    // Strokes that merely overlapped would leave one unbroken run of ink
    // across the loop; the weave's knockout gaps break it into several.
    var bestRuns = 0;
    for (var y = (_size * 0.35).toInt(); y < (_size * 0.75).toInt(); y++) {
      var runs = 0;
      var wasInk = false;
      for (var x = 0; x < _size; x++) {
        final ink = _alphaAt(pixels, x, y) > 8;
        if (ink && !wasInk) runs++;
        wasInk = ink;
      }
      if (runs > bestRuns) bestRuns = runs;
    }

    expect(
      bestRuns,
      greaterThanOrEqualTo(3),
      reason: 'expected separate ink runs where the Z and V cross',
    );
  });
}
