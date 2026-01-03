// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:choreflow_flutter/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DutySpinApp(firebaseReady: false));

    // Allow one (or a few) frames for async hydration.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.bySemanticsLabel('DutySpin'), findsOneWidget);
  });
}
