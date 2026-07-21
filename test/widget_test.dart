import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/app.dart';

void main() {
  testWidgets('ZivybbApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ZivybbApp());

    expect(find.text('Zivybb'), findsOneWidget);
  });
}
