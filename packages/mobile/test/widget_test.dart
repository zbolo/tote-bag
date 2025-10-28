import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_bag/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ToteBagApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(ToteBagApp), findsOneWidget);
  });
}
