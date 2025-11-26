import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/forecast.dart';
import '../theme/app_colors.dart';

/// Large tappable forecast card.
class ForecastCard extends StatelessWidget {
  final BiteForecast forecast;
  final VoidCallback? onTap;

  const ForecastCard({
    super.key,
    required this.forecast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildContent(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isToday = _isToday(forecast.date);
    final dateLabel = isToday
        ? 'Today'
        : DateFormat('EEEE, MMM d').format(forecast.date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(forecast.overallScore),
            _getScoreColor(forecast.overallScore).withAlpha(180),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                forecast.ratingLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
          _BiteScoreIndicator(score: forecast.overallScore),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            forecast.summary,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildHourlyPreview(),
        ],
      ),
    );
  }

  Widget _buildHourlyPreview() {
    // Show best 4 hours
    final topHours = forecast.hourlyPredictions.toList()
      ..sort((a, b) => b.biteScore.compareTo(a.biteScore));
    final bestHours = topHours.take(4).toList()
      ..sort((a, b) => a.hour.hour.compareTo(b.hour.hour));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: bestHours.map((hour) {
        return Column(
          children: [
            Text(
              DateFormat('ha').format(hour.hour).toLowerCase(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getScoreColor(hour.biteScore).withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getScoreColor(hour.biteScore),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  hour.biteScore.round().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(hour.biteScore),
                  ),
                ),
              ),
            ),
            if (hour.isSolunarPeak) ...[
              const SizedBox(height: 2),
              const Icon(
                Icons.star,
                size: 12,
                color: AppColors.accentGold,
              ),
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surfaceElevated),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 16, color: AppColors.accentGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              forecast.tips.isNotEmpty ? forecast.tips.first : '',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primaryGreen;
    if (score >= 40) return AppColors.accentOrange;
    return AppColors.error;
  }
}

class _BiteScoreIndicator extends StatelessWidget {
  final double score;

  const _BiteScoreIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.round().toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'BITE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
