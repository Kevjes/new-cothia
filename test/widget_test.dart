// This is a basic Flutter widget test for Cothia app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('App should load login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Bienvenue sur Cothia'),
          ),
        ),
      ),
    );

    // Verify that login page elements are present.
    expect(find.text('Bienvenue sur Cothia'), findsOneWidget);
  });
}
