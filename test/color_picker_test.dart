import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/core/utils/color_hex.dart';
import 'package:zivybb/shared/widgets/color_swatch_picker.dart';
import 'package:zivybb/shared/widgets/custom_color_picker.dart';

const _palette = <Color>[Color(0xFFFF7043), Color(0xFF4FC3F7)];

/// Pumps a swatch picker and records what it reports back.
Future<List<Color>> _pumpSwatches(
  WidgetTester tester, {
  required String selectedHex,
  bool allowCustom = true,
}) async {
  final picked = <Color>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ColorSwatchPicker(
          selectedHex: selectedHex,
          palette: _palette,
          allowCustom: allowCustom,
          onSelected: picked.add,
        ),
      ),
    ),
  );
  return picked;
}

/// Opens the dialog straight onto [initial] and records the chosen color.
Future<List<Color>> _pumpDialog(
  WidgetTester tester, {
  required Color initial,
}) async {
  final picked = <Color>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final color = await CustomColorPickerDialog.show(
                context,
                initialColor: initial,
              );
              if (color != null) picked.add(color);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return picked;
}

/// Drags to a fractional position inside the keyed surface.
Future<void> _dragTo(
  WidgetTester tester,
  Key key, {
  required double x,
  required double y,
}) async {
  final rect = tester.getRect(find.byKey(key));
  // Start the drag in the middle so the gesture is unambiguous, then move to
  // the target: the field reads the pointer's position, not the distance.
  final start = rect.center;
  final target = Offset(
    rect.left + rect.width * x,
    rect.top + rect.height * y,
  );
  await tester.dragFrom(start, target - start);
  await tester.pump();
}

String _hexInField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  group('CustomColorPickerDialog', () {
    testWidgets('opens on the color it was given', (tester) async {
      await _pumpDialog(tester, initial: const Color(0xFF4FC3F7));
      expect(_hexInField(tester), '4FC3F7');
    });

    testWidgets('a typed hex becomes the result', (tester) async {
      final picked = await _pumpDialog(tester, initial: const Color(0xFFFF7043));

      await tester.enterText(find.byType(TextField), '3B82F6');
      await tester.pump();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(picked.single.toARGB32(), const Color(0xFF3B82F6).toARGB32());
    });

    testWidgets('an incomplete hex is ignored rather than parsed short', (
      tester,
    ) async {
      final picked = await _pumpDialog(tester, initial: const Color(0xFFFF7043));

      // '3B8' is valid hex but only half a color — treating it as 0x0003B8
      // would recolor the swatch to near-black mid-keystroke.
      await tester.enterText(find.byType(TextField), '3B8');
      await tester.pump();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(picked.single.toARGB32(), const Color(0xFFFF7043).toARGB32());
    });

    testWidgets('cancelling reports nothing', (tester) async {
      final picked = await _pumpDialog(tester, initial: const Color(0xFFFF7043));

      await tester.enterText(find.byType(TextField), '3B82F6');
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(picked, isEmpty);
    });

    testWidgets('dragging the hue slider spans the spectrum', (tester) async {
      await _pumpDialog(tester, initial: const Color(0xFFFF0000));

      await _dragTo(tester, hueSliderKey, x: 0.0, y: 0.5);
      expect(_hexInField(tester), 'FF0000', reason: 'the left edge is red');

      await _dragTo(tester, hueSliderKey, x: 1 / 3, y: 0.5);
      expect(_hexInField(tester), '00FF00', reason: 'a third along is green');

      await _dragTo(tester, hueSliderKey, x: 2 / 3, y: 0.5);
      expect(_hexInField(tester), '0000FF', reason: 'two thirds along is blue');
    });

    testWidgets('the field corners are white, black, and the full hue', (
      tester,
    ) async {
      await _pumpDialog(tester, initial: const Color(0xFF00FF00));

      await _dragTo(tester, saturationValueFieldKey, x: 0.0, y: 0.0);
      expect(_hexInField(tester), 'FFFFFF');

      await _dragTo(tester, saturationValueFieldKey, x: 1.0, y: 0.0);
      expect(_hexInField(tester), '00FF00');

      await _dragTo(tester, saturationValueFieldKey, x: 0.5, y: 1.0);
      expect(_hexInField(tester), '000000');
    });

    testWidgets('going through black keeps the hue', (tester) async {
      // The reason the dialog holds an HSVColor rather than a Color: black
      // has no hue to recover, so a round trip through Color would snap the
      // field back to red the moment brightness touched zero.
      await _pumpDialog(tester, initial: const Color(0xFF00FF00));

      await _dragTo(tester, saturationValueFieldKey, x: 1.0, y: 1.0);
      expect(_hexInField(tester), '000000');

      await _dragTo(tester, saturationValueFieldKey, x: 1.0, y: 0.0);
      expect(_hexInField(tester), '00FF00');
    });
  });

  group('ColorSwatchPicker', () {
    testWidgets('offers the wheel only when custom colors are allowed', (
      tester,
    ) async {
      await _pumpSwatches(
        tester,
        selectedHex: '#FF7043',
        allowCustom: false,
      );
      expect(find.byTooltip('Custom color'), findsNothing);

      await _pumpSwatches(tester, selectedHex: '#FF7043');
      expect(find.byTooltip('Custom color'), findsOneWidget);
    });

    testWidgets('the wheel reports the color chosen in the dialog', (
      tester,
    ) async {
      final picked = await _pumpSwatches(tester, selectedHex: '#FF7043');

      await tester.tap(find.byTooltip('Custom color'));
      await tester.pumpAndSettle();
      // The dialog should start from the swatch picker's current color.
      expect(_hexInField(tester), 'FF7043');

      await tester.enterText(find.byType(TextField), '112233');
      await tester.pump();
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(picked.single.toARGB32(), const Color(0xFF112233).toARGB32());
    });

    testWidgets('a color outside the palette still reads as selected', (
      tester,
    ) async {
      // Off-palette means the check mark has nowhere to sit, so the wheel
      // takes over as the selection indicator.
      await _pumpSwatches(tester, selectedHex: '#112233');
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);

      await _pumpSwatches(tester, selectedHex: '#FF7043');
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  test('hex round trip survives the picker', () {
    for (final hex in ['#FF7043', '#000000', '#FFFFFF', '#3B82F6']) {
      expect(colorToHex(colorFromHex(hex)), hex);
    }
  });
}
