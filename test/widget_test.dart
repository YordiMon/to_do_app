// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_app/main.dart';

void main() {
  testWidgets('Add todo item test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(ToDoApp());

    // Verify that the list is empty at start
    expect(find.byType(ListTile), findsNothing);

    // Enter text in the TextField
    await tester.enterText(find.byType(TextField), 'Test Todo');
    
    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our todo item was added
    expect(find.text('Test Todo'), findsOneWidget);
    
    // Verify checkbox exists and is unchecked
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, false);
  });
}
