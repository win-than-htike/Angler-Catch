import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/forecast_card.dart';
import '../../data/providers/app_state.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.mapDark,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.mapDark,
          body: RefreshIndicator(
            onRefresh: appState.refreshForecasts,
            color: AppColors.accentOrange,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, appState),
                SliverToBoxAdapter(child: _buildTodayHighlight(appState)),
                SliverToBoxAdapter(child: _buildHourlyChart(appState)),
                SliverToBoxAdapter(child: _buildWeatherInfo(appState)),
                _buildWeeklyForecast(appState),
              ],
            ),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppState appState) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.mapDark,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Bite Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryGreen.withAlpha(100),
                AppColors.mapDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: appState.refreshForecasts,
        ),
      ],
    );
  }

  Widget _buildTodayHighlight(AppState appState) {
    final bestTime = appState.getBestBiteTime();
    final todayForecast = appState.biteForecast.isNotEmpty
        ? appState.biteForecast.first
        : null;

    if (todayForecast == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(todayForecast.overallScore),
            _getScoreColor(todayForecast.overallScore).withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(todayForecast.overallScore).withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Bite Rating',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayForecast.ratingLabel,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${todayForecast.overallScore.round()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (bestTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Best Time: ${DateFormat('h:mm a').format(bestTime.hour)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bestTime.biteScore.round()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(todayForecast.overallScore),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHourlyChart(AppState appState) {
    if (appState.biteForecast.isEmpty) return const SizedBox.shrink();

    final selectedForecast = appState.biteForecast[_selectedDayIndex];
    final predictions = selectedForecast.hourlyPredictions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hourly Bite Probability',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Peak',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: predictions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hour = entry.value;
                  final barHeight = (hour.biteScore / 100) * 140;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == predictions.length - 1 ? 0 : 4,
                    ),
                    child: _HourlyBarItem(
                      hour: hour.hour,
                      score: hour.biteScore,
                      barHeight: barHeight,
                      isSolunarPeak: hour.isSolunarPeak,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(AppState appState) {
    if (appState.weatherForecast.isEmpty) return const SizedBox.shrink();

    final weather = appState.weatherForecast[_selectedDayIndex];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Conditions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem(
                Icons.thermostat,
                '${weather.tempHigh.round()}°/${weather.tempLow.round()}°',
                'Temp',
              ),
              _buildWeatherItem(
                Icons.air,
                '${weather.windSpeed.round()} mph',
                'Wind',
              ),
              _buildWeatherItem(
                Icons.compress,
                '${weather.pressure.round()} hPa',
                'Pressure',
              ),
              _buildWeatherItem(
                Icons.nightlight_round,
                weather.moonPhaseName.split(' ').first,
                'Moon',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentOrange, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  SliverList _buildWeeklyForecast(AppState appState) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }

        final forecastIndex = index - 1;
        if (forecastIndex >= appState.biteForecast.length) {
          return null;
        }

        final forecast = appState.biteForecast[forecastIndex];
        return ForecastCard(
          forecast: forecast,
          onTap: () {
            setState(() => _selectedDayIndex = forecastIndex);
          },
        );
      }, childCount: appState.biteForecast.length + 1),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primaryGreen;
    if (score >= 40) return AppColors.accentOrange;
    return AppColors.error;
  }
}

class _HourlyBarItem extends StatelessWidget {
  const _HourlyBarItem({
    required this.hour,
    required this.score,
    required this.barHeight,
    required this.isSolunarPeak,
  });

  final DateTime hour;
  final double score;
  final double barHeight;
  final bool isSolunarPeak;

  Color _getBarColor() {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primaryGreen;
    if (score >= 40) return AppColors.accentOrange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isSolunarPeak)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            '${score.round()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSolunarPeak ? AppColors.accentGold : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 28,
            height: barHeight.clamp(8.0, 140.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_getBarColor(), _getBarColor().withAlpha(180)],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: isSolunarPeak
                  ? [
                      BoxShadow(
                        color: AppColors.accentGold.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('ha').format(hour).toLowerCase(),
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
