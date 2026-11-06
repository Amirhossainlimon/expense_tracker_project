import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/app.dart';

void main() {
  testWidgets('CashTrack app renders successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(ExpenseTrackerApp());

    await tester.pump();

    expect(find.byType(ExpenseTrackerApp), findsOneWidget);
  });
}
