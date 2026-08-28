import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riyaheen_aljinan/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // ✅ إصلاح: RiyaheenApp بدلاً من MyApp
    await tester.pumpWidget(const RiyaheenApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
