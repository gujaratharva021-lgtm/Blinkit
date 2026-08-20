// Basic smoke test: verifies the app builds and renders its first frame
// without throwing, using a real ThemeProvider (MyApp requires one).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mepto_clone/main.dart';
import 'package:mepto_clone/core/theme/theme_provider.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(MyApp(themeProvider: themeProvider));
    await tester.pump();

    // The app should have rendered a MaterialApp at the root.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
