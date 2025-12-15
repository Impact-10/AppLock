import 'package:flutter_test/flutter_test.dart';

import 'package:activity_locker_mvp/src/app.dart';

void main() {
  testWidgets('Activity Locker app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ActivityLockerApp());
    expect(find.text('Activity Locker'), findsOneWidget);
  });
}
