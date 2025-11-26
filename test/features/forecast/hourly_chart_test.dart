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

    testWidgets('displays hourly chart with scrollable bar design', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the horizontal scroll view for the bar chart
      final scrollViewFinder = find.byType(SingleChildScrollView);
      expect(
        scrollViewFinder,
        findsWidgets,
        reason: 'Should have scrollable chart area',
      );

      // Verify the chart title is displayed
      expect(find.text('Hourly Bite Probability'), findsOneWidget);
    });

    testWidgets('displays solunar peak indicator in legend', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify legend shows "Peak" indicator
      expect(
        find.text('Peak'),
        findsOneWidget,
        reason: 'Should show Peak indicator in legend',
      );
    });

    testWidgets('displays hourly bars for all predictions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify hourly time labels are displayed
      // Check for a few specific hours that should be visible
      expect(
        find.text('12am'),
        findsWidgets,
        reason: 'Should display 12am time label',
      );
    });

    testWidgets('chart header displays correctly without overlap', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify header text is fully visible
      expect(find.text('Hourly Bite Probability'), findsOneWidget);
      expect(find.text('Peak'), findsOneWidget);

      // Verify the container for chart exists
      final chartContainer = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(16),
      );
      expect(
        chartContainer,
        findsWidgets,
        reason: 'Chart container should exist with proper styling',
      );
    });

    testWidgets('chart is horizontally scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find horizontal scroll view with BouncingScrollPhysics
      final scrollView = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );

      expect(
        scrollView,
        findsOneWidget,
        reason: 'Should have horizontal scroll capability',
      );
    });

    testWidgets('displays score values above bars', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final predictions = mockAppState.biteForecast.first.hourlyPredictions;

      // Check that at least some score values are displayed
      // Scores are displayed as rounded integers
      var foundScores = 0;
      for (final prediction in predictions) {
        final scoreText = find.text('${prediction.biteScore.round()}');
        if (scoreText.evaluate().isNotEmpty) {
          foundScores++;
        }
      }

      expect(
        foundScores,
        greaterThan(0),
        reason: 'Should display score values above bars',
      );
    });
  });
}
