import 'package:flutter/material.dart';
import '../services/streak_service.dart';

class StreakStatsWidget extends StatefulWidget {
  final String userId;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final Color? mutedColor;

  const StreakStatsWidget({
    super.key,
    required this.userId,
    this.primaryColor,
    this.backgroundColor,
    this.surfaceColor,
    this.mutedColor,
  });

  @override
  State<StreakStatsWidget> createState() => _StreakStatsWidgetState();
}

class _StreakStatsWidgetState extends State<StreakStatsWidget> {
  final StreakService _streakService = StreakService();

  StreakStats? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final stats =
          await _streakService.getStreakStats(widget.userId);

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? Colors.orange;
    final background = widget.backgroundColor ?? Colors.transparent;
    final surface = widget.surfaceColor ?? Colors.white;
    final muted = widget.mutedColor ?? Colors.grey;

    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text('Unable to load streak'),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = _stats!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: primary,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                'Workout Streak',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  value: '${stats.currentStreak}',
                  label: 'Current Streak',
                  color: primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  value: '${stats.longestStreak}',
                  label: 'Longest Streak',
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fitness_center,
                  value: '${stats.totalWorkouts}',
                  label: 'Total Workouts',
                  color: primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  value: '${stats.workoutsThisWeek}',
                  label: 'This Week',
                  color: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}