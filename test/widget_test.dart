// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rivals/main.dart';

void main() {
  testWidgets('home dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Good Morning, Alex'), findsOneWidget);
    expect(find.text('Daily Streak'), findsOneWidget);
    expect(find.text('12 Days'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('PUSH DAY'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('PUSH DAY'), findsOneWidget);
    expect(find.text('START WORKOUT  →'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Active Challenge'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Active Challenge'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Friends Training Now'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Friends Training Now'), findsOneWidget);
    expect(find.text('Rahul'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
