import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('AmberDesign app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const AmberDesignApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
