import 'package:angler_catch/data/providers/app_state.dart';
import 'package:angler_catch/features/forecast/forecast_screen.dart';
import 'package:fl_chart/fl_chart.dart';
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

    testWidgets('displays hourly chart without permanent tooltips', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the BarChart widget
      final barChartFinder = find.byType(BarChart);
      expect(barChartFinder, findsOneWidget);

      // Verify chart is displayed
      final barChart = tester.widget<BarChart>(barChartFinder);
      final data = barChart.data;

      // Verify no bars have permanent tooltip indicators
      // (this was the bug: showingTooltipIndicators was set for solunar peaks)
      for (final group in data.barGroups) {
        expect(
          group.showingTooltipIndicators,
          isEmpty,
          reason: 'Bar groups should not have permanent tooltip indicators',
        );
      }
    });

    testWidgets(
      'solunar peak bars have background highlight instead of tooltip',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final barChartFinder = find.byType(BarChart);
        final barChart = tester.widget<BarChart>(barChartFinder);
        final data = barChart.data;

        // Find bars that correspond to solunar peak hours
        final predictions = mockAppState.biteForecast.first.hourlyPredictions;
        final solunarPeakIndices = <int>[];
        for (var i = 0; i < predictions.length; i++) {
          if (predictions[i].isSolunarPeak) {
            solunarPeakIndices.add(i);
          }
        }

        // Verify solunar peak bars have background highlight
        for (final index in solunarPeakIndices) {
          final group = data.barGroups[index];
          final rod = group.barRods.first;
          expect(
            rod.backDrawRodData,
            isNotNull,
            reason: 'Solunar peak bars should have background highlight',
          );
          expect(
            rod.backDrawRodData.show,
            isTrue,
            reason: 'Background highlight should be visible',
          );
        }
      },
    );

    testWidgets('bottom titles have reserved space to prevent clipping', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final barChartFinder = find.byType(BarChart);
      final barChart = tester.widget<BarChart>(barChartFinder);
      final data = barChart.data;

      // Verify bottom titles have reserved size
      final bottomTitles = data.titlesData.bottomTitles;
      expect(
        bottomTitles.sideTitles.reservedSize,
        greaterThanOrEqualTo(28),
        reason: 'Bottom titles should have reserved space to prevent clipping',
      );
    });

    testWidgets('tooltips are configured to fit inside chart bounds', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final barChartFinder = find.byType(BarChart);
      final barChart = tester.widget<BarChart>(barChartFinder);
      final data = barChart.data;

      // Verify tooltip configuration prevents overflow
      final tooltipData = data.barTouchData.touchTooltipData;
      expect(
        tooltipData.fitInsideHorizontally,
        isTrue,
        reason: 'Tooltips should fit inside horizontal bounds',
      );
      expect(
        tooltipData.fitInsideVertically,
        isTrue,
        reason: 'Tooltips should fit inside vertical bounds',
      );
    });

    testWidgets('time labels are shown at 6-hour intervals', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for time labels (12am, 6am, 12pm, 6pm pattern)
      // These are displayed as lowercase with 'ha' format (e.g., "12am", "6am")
      expect(find.text('12am'), findsOneWidget);
      expect(find.text('6am'), findsOneWidget);
      expect(find.text('12pm'), findsOneWidget);
      expect(find.text('6pm'), findsOneWidget);
    });

    testWidgets('chart header displays correctly without overlap', (
      tester,
    ) async {
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
  });
}
