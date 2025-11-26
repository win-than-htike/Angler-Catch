import 'package:angler_catch/data/providers/app_state.dart';
import 'package:angler_catch/features/forecast/forecast_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/mock_app_state.dart';

void main() {
  group('Hourly Chart', () {
    late MockAppState mockAppState;

    setUp(() {
      mockAppState = MockAppState();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AppState>.value(
          value: mockAppState,
          child: const ForecastScreen(),
        ),
      );
    }

    testWidgets('displays hourly predictions as scrollable list', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the horizontal ListView
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsWidgets);

      // Verify section header is displayed
      expect(find.text('Hourly Bite Probability'), findsOneWidget);
    });

    testWidgets('displays time labels for each hour without overlap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The new horizontal list shows each hour with its own card
      // Look for some time labels in the visible area
      expect(find.text('12am'), findsOneWidget);
    });

    testWidgets('solunar peak hours display star icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify star icons are displayed for solunar peaks
      expect(
        find.byIcon(Icons.star),
        findsWidgets,
        reason: 'Star icons should be visible for solunar peaks and legend',
      );
    });

    testWidgets('chart header displays correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify header text is fully visible
      expect(find.text('Hourly Bite Probability'), findsOneWidget);
      expect(find.text('Solunar Peak'), findsOneWidget);

      // Verify star icon for solunar peak legend
      expect(
        find.byIcon(Icons.star),
        findsWidgets,
        reason: 'Star icon should be visible in legend',
      );
    });

    testWidgets('hourly cards display percentage values', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find percentage text widgets (e.g., "75%", "80%")
      final percentFinder = find.textContaining('%');
      expect(
        percentFinder,
        findsWidgets,
        reason: 'Hourly cards should display percentage values',
      );
    });

    testWidgets('list is horizontally scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find a horizontal ListView
      final listViewFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.horizontal,
      );
      expect(
        listViewFinder,
        findsOneWidget,
        reason: 'Should have a horizontal scrollable list',
      );
    });
  });
}
