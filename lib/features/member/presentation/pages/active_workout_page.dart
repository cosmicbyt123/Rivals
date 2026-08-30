import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';

class ActiveWorkoutPage extends ConsumerStatefulWidget {
  const ActiveWorkoutPage({super.key});

  @override
  ConsumerState<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends ConsumerState<ActiveWorkoutPage> {
  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Barbell Back Squat',
      'target': '4 Sets • 200kg target',
      'sets': [
        {'set': 1, 'prev': '180kg x 8', 'kg': '180', 'reps': '8', 'isCompleted': true, 'isPr': false},
        {'set': 2, 'prev': '190kg x 6', 'kg': '190', 'reps': '6', 'isCompleted': true, 'isPr': false},
        {'set': 3, 'prev': '200kg x 6', 'kg': '205', 'reps': '6', 'isCompleted': true, 'isPr': true},
        {'set': 4, 'prev': '200kg x 5', 'kg': '200', 'reps': '5', 'isCompleted': true, 'isPr': false},
      ],
    },
    {
      'name': 'Romanian Deadlift',
      'target': '3 Sets • 140kg target',
      'sets': [
        {'set': 1, 'prev': '140kg x 8', 'kg': '140', 'reps': '8', 'isCompleted': true, 'isPr': false},
        {'set': 2, 'prev': '140kg x 8', 'kg': '145', 'reps': '8', 'isCompleted': true, 'isPr': false},
        {'set': 3, 'prev': '150kg x 6', 'kg': '150', 'reps': '6', 'isCompleted': false, 'isPr': false},
      ],
    },
    {
      'name': 'Bulgarian Split Squats',
      'target': '3 Sets • 32kg Dumbbells',
      'sets': [
        {'set': 1, 'prev': '32kg x 10', 'kg': '32', 'reps': '10', 'isCompleted': false, 'isPr': false},
        {'set': 2, 'prev': '32kg x 10', 'kg': '32', 'reps': '10', 'isCompleted': false, 'isPr': false},
      ],
    },
  ];

  double _totalVolume = 0;
  int _completedSets = 0;
  int _totalSets = 0;

  @override
  void initState() {
    super.initState();
    _recalculateMetrics();
  }

  void _recalculateMetrics() {
    double vol = 0;
    int completed = 0;
    int total = 0;

    for (final ex in _exercises) {
      final sets = ex['sets'] as List<Map<String, dynamic>>;
      total += sets.length;
      for (final s in sets) {
        if (s['isCompleted'] == true) {
          completed++;
          final kg = double.tryParse(s['kg'].toString()) ?? 0;
          final reps = double.tryParse(s['reps'].toString()) ?? 0;
          vol += (kg * reps);
        }
      }
    }

    _totalVolume = vol;
    _completedSets = completed;
    _totalSets = total;
  }

  void _toggleSet(Map<String, dynamic> s) {
    setState(() {
      s['isCompleted'] = !(s['isCompleted'] == true);
      _recalculateMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressPct = _totalSets > 0 ? (_completedSets / _totalSets) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _ActiveHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLiveWorkoutMetricsBar(context, _totalVolume, _completedSets, _totalSets, progressPct),
                    const SizedBox(height: 24),
                    ..._exercises.asMap().entries.map((entry) {
                      return _buildExerciseBlock(context, entry.key, entry.value);
                    }),
                    const SizedBox(height: 20),
                    ClayButton(
                      onPressed: () => _finishWorkout(context, _totalVolume),
                      height: 52,
                      borderRadius: 16,
                      color: AppColors.primary,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.onPrimary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Finish Workout & Sync XP (+120 XP)',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveWorkoutMetricsBar(
      BuildContext context, double totalVol, int completedSets, int totalSets, double progress) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricStat('VOLUME', '${(totalVol / 1000).toStringAsFixed(1)} Tons', AppColors.primary),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              _buildMetricStat('SETS DONE', '$completedSets / $totalSets', AppColors.onSurface),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              _buildMetricStat('PROGRESS', '${(progress * 100).toInt()}%', const Color(0xFF00E676)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.outline, fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildExerciseBlock(BuildContext context, int exIndex, Map<String, dynamic> exercise) {
    final sets = exercise['sets'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise['name'] as String,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  exercise['target'] as String,
                  style: const TextStyle(color: AppColors.outline, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Set Table Header
            const Row(
              children: [
                SizedBox(width: 32, child: Text('SET', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w700))),
                Expanded(child: Text('PREVIOUS', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w700))),
                SizedBox(width: 60, child: Text('KG', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w700))),
                SizedBox(width: 48, child: Text('REPS', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w700))),
                SizedBox(width: 36, child: Icon(Icons.check, size: 14, color: AppColors.outline)),
              ],
            ),
            const SizedBox(height: 8),
            ...sets.map((s) {
              final isCompleted = s['isCompleted'] == true;
              final isPr = s['isPr'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text('${s['set']}', style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text('${s['prev']}', style: const TextStyle(color: AppColors.outline, fontSize: 11)),
                          if (isPr) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('PR!', style: TextStyle(color: AppColors.onPrimary, fontSize: 8, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${s['kg']}', style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text('${s['reps']}', style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    SizedBox(
                      width: 36,
                      child: GestureDetector(
                        onTap: () => _toggleSet(s),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? const Color(0xFF00E676) : AppColors.surfaceContainerHigh,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: isCompleted ? Colors.black : AppColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _finishWorkout(BuildContext context, double totalVol) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Workout Logged!', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Great lift! Your session has been recorded to Supabase.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 12),
              Text('• Total Volume: ${(totalVol / 1000).toStringAsFixed(1)} Tons', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              const Text('• Daily Streak: 27 Days (+1)', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700)),
              const Text('• XP Earned: +120 XP', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            ClayButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              height: 40,
              borderRadius: 10,
              color: AppColors.primary,
              child: const Text('Awesome!', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }
}

class _ActiveHeader extends StatelessWidget {
  const _ActiveHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: AppColors.darkShadow,
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const NeumorphicContainer(
                  padding: EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hypertrophy Block A',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Live Gym Floor Sync',
                        style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const _WorkoutTimerBadge(initialSeconds: 2100),
        ],
      ),
    );
  }
}

class _WorkoutTimerBadge extends StatefulWidget {
  final int initialSeconds;
  const _WorkoutTimerBadge({required this.initialSeconds});

  @override
  State<_WorkoutTimerBadge> createState() => _WorkoutTimerBadgeState();
}

class _WorkoutTimerBadgeState extends State<_WorkoutTimerBadge> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
