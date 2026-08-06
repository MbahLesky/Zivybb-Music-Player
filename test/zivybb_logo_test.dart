import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/shared/widgets/zivybb_logo.dart';

void main() {
  testWidgets('renders the brand artwork at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo(size: 40))),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 40);
    expect(image.height, 40);
    expect(tester.getSize(find.byType(Image)), const Size(40, 40));
  });

  testWidgets('points at the artwork the launcher icons are cut from', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo())),
    );

    // tool/generate_icons.dart reads this same path; if one moves without the
    // other, the in-app logo and the launcher icon drift apart.
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      ZivybbLogo.assetPath,
      reason: 'keep in step with tool/generate_icons.dart',
    );
    expect(ZivybbLogo.assetPath, 'assets/images/zivybb_logo.png');
  });

  testWidgets('carries a semantic label by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo())),
    );

    expect(tester.widget<Image>(find.byType(Image)).semanticLabel, 'Zivybb');
  });
}
