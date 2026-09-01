import 'package:flutter/material.dart';
import '../services/streak_service.dart';

class StreakStatsWidget extends StatefulWidget {
  final String userId;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final Color? mutedColor;

  const StreakStatsWidget({
    Key? key,
    required this.userId,
    this.primaryColor,
    this.backgroundColor,
    this.surfaceColor,
    this.mutedColor,
  }) : super(key: key);

  @override
  State<StreakStatsWidget> createState() => _StreakStatsWidgetState();
}

class _StreakStatsWidgetState extends State<StreakStatsWidget> {
  final StreakService _streakService = StreakService();
  late Future<StreakData> _streakDataFuture;

  @override
  void initState() {
    super.initState();
    _streakDataFuture = _streakService.getUserStreakData();
  }

  Color get _primaryColor => widget.primaryColor ?? const Color(0xFFFFC83D);
  Color get _backgroundColor => widget.backgroundColor ?? const Color(0xFF101010);
  Color get _surfaceColor => widget.surfaceColor ?? const Color(0xFF191919);
  Color get _mutedColor => widget.mutedColor ?? const Color(0xFFB9B3A8);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StreakData>(
      future: _streakDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CircularProgressIndicator(color: _primaryColor),
            ),
          );
        }

        final streakData = snapshot.data;
        if (streakData == null) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Unable to load streak data',
              style: TextStyle(color: _mutedColor),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Streak Stats',
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow(
                'Current Streak',
                '${streakData.currentStreak}',
                Icons.local_fire_department,
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                'Longest Streak',
                '${streakData.longestStreak}',
                Icons.trending_up,
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                'Total Workouts',
                '${streakData.totalWorkouts}',
                Icons.fitness_center,
              ),
              if (streakData.lastStreakDate != null) ...[
                const SizedBox(height: 16),
                _buildStatRow(
                  'Last Activity',
                  _formatDate(streakData.lastStreakDate!),
                  Icons.calendar_today,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Compact streak card widget - useful for dashboard displays
class CompactStreakCard extends StatefulWidget {
  final Color? primaryColor;
  final Color? surfaceColor;
  final Color? mutedColor;
  final VoidCallback? onTap;

  const CompactStreakCard({
    Key? key,
    this.primaryColor,
    this.surfaceColor,
    this.mutedColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<CompactStreakCard> createState() => _CompactStreakCardState();
}

class _CompactStreakCardState extends State<CompactStreakCard> {
  final StreakService _streakService = StreakService();
  late Future<StreakData> _streakDataFuture;

  @override
  void initState() {
    super.initState();
    _streakDataFuture = _streakService.getUserStreakData();
  }

  Color get _primaryColor => widget.primaryColor ?? const Color(0xFFFFC83D);
  Color get _surfaceColor => widget.surfaceColor ?? const Color(0xFF191919);
  Color get _mutedColor => widget.mutedColor ?? const Color(0xFFB9B3A8);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StreakData>(
      future: _streakDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CircularProgressIndicator(color: _primaryColor),
          );
        }

        final streakData = snapshot.data;
        if (streakData == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: _primaryColor, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: _mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${streakData.currentStreak} days',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Best',
                      style: TextStyle(
                        color: _mutedColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${streakData.longestStreak}d',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
