import 'package:flutter_test/flutter_test.dart';

import 'package:trimit/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TrimItApp());
    await tester.pumpAndSettle();
    expect(find.text('TrimIt - Database Test'), findsOneWidget);
  });
}