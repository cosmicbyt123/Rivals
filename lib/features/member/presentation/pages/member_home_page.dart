import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../providers/members_provider.dart';
import '../../../../repositories/member_repository.dart';

class MemberHomePage extends ConsumerStatefulWidget {
  const MemberHomePage({super.key});

  @override
  ConsumerState<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends ConsumerState<MemberHomePage> {
  int _selectedDayIndex = 3; // Wednesday (Today)

  final List<Map<String, dynamic>> _weekDays = [
    {'day': 'M', 'date': '25', 'status': 'completed'},
    {'day': 'T', 'date': '26', 'status': 'completed'},
    {'day': 'W', 'date': '27', 'status': 'completed'},
    {'day': 'T', 'date': '28', 'status': 'today'},
    {'day': 'F', 'date': '29', 'status': 'future'},
    {'day': 'S', 'date': '30', 'status': 'rest_day'},
    {'day': 'S', 'date': '31', 'status': 'future'},
  ];

  @override
  Widget build(BuildContext context) {
    final memberStatsAsync = ref.watch(memberDashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    memberStatsAsync.when(
                      loading: () => const ShimmerSkeleton(width: double.infinity, height: 120),
                      error: (e, st) => Text('Error loading stats: $e', style: const TextStyle(color: AppColors.outline)),
                      data: (stats) => _buildStreakAndConsistencyRow(context, stats),
                    ),
                    const SizedBox(height: 24),
                    _buildWeeklyCalendar(),
                    const SizedBox(height: 24),
                    _buildTodayWorkoutCard(context, memberStatsAsync),
                    const SizedBox(height: 28),
                    _buildPersonalRecordsBento(context),
                    const SizedBox(height: 28),
                    _buildLiveFriendActivityFeed(context),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildMemberBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP',
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Arjun Verma',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PLATINUM',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Iron Forge Fitness • 6,400 XP',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
                },
                child: NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  borderRadius: 12,
                  child: const Row(
                    children: [
                      Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Owner View',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakAndConsistencyRow(BuildContext context, MemberDashboardData stats) {
    return Row(
      children: [
        // Daily Streak Card
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.local_fire_department, color: Color(0xFFFF7043), size: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7043).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'BEST ${stats.longestStreak}D',
                        style: const TextStyle(
                          color: Color(0xFFFF7043),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${stats.currentStreak} Days',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        fontSize: 22,
                      ),
                ),
                const Text(
                  'CURRENT STREAK',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Monthly Consistency Card
        Expanded(
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.primary, size: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AUGUST',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${stats.monthlyConsistency.toInt()}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                ),
                const Text(
                  'CONSISTENCY',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_weekDays.length, (index) {
          final day = _weekDays[index];
          final status = day['status'] as String;
          final isCompleted = status == 'completed';
          final isToday = status == 'today';
          final isRest = status == 'rest_day';
          final isSelected = _selectedDayIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary
                    : isSelected
                        ? AppColors.surfaceContainerHighest
                        : isCompleted
                            ? AppColors.surfaceContainerHigh
                            : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? null
                    : Border.all(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.6) : AppColors.outlineVariant,
                      ),
              ),
              child: Column(
                children: [
                  Text(
                    day['day'] as String,
                    style: TextStyle(
                      color: isToday ? AppColors.onPrimary : AppColors.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day['date'] as String,
                    style: TextStyle(
                      color: isToday ? AppColors.onPrimary : AppColors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 12)
                  else if (isRest)
                    const Icon(Icons.hotel, color: AppColors.outline, size: 12)
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTodayWorkoutCard(BuildContext context, AsyncValue<MemberDashboardData> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S ASSIGNED WORKOUT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Hypertrophy Block A',
              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 14),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Heavy Squat & Lower Body Power',
                        style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '5 Exercises • ~65 mins • Target RPE 8.5',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: 14),
              _buildExerciseRow('1. Barbell Back Squat', '4 Sets x 6-8 Reps (200kg target)'),
              _buildExerciseRow('2. Romanian Deadlifts', '3 Sets x 8-10 Reps (140kg)'),
              _buildExerciseRow('3. Bulgarian Split Squats', '3 Sets x 10 Reps each leg'),
              _buildExerciseRow('4. Standing Calf Raises', '4 Sets x 15 Reps'),
              const SizedBox(height: 18),
              ClayButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.activeWorkout);
                },
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: AppColors.onPrimary, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Start Live Workout Session',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseRow(String name, String setsReps) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: AppColors.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(setsReps, style: const TextStyle(color: AppColors.outline, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPersonalRecordsBento(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'YOUR BIG 3 PERSONAL RECORDS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              '655 kg Total',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildPrCard('DEADLIFT', '290 kg', 'Gym Record 👑', AppColors.primary),
            const SizedBox(width: 10),
            _buildPrCard('SQUAT', '225 kg', '+10kg this mo', AppColors.secondary),
            const SizedBox(width: 10),
            _buildPrCard('BENCH', '140 kg', 'PR 2w ago', const Color(0xFFEEC05B)),
          ],
        ),
      ],
    );
  }

  Widget _buildPrCard(String lift, String weight, String badge, Color color) {
    return Expanded(
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lift, style: const TextStyle(color: AppColors.outline, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              weight,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(badge, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveFriendActivityFeed(BuildContext context) {
    final activities = [
      {'user': 'Rahul Sen', 'action': 'completed Squat & Core (240kg PR)', 'time': '15m ago', 'avatar': 'RS'},
      {'user': 'Tanya Malik', 'action': 'won 1v1 Deadlift Duel (+120 XP)', 'time': '1h ago', 'avatar': 'TM'},
      {'user': 'Devansh Chawla', 'action': 'hit 14-Day Workout Streak', 'time': '3h ago', 'avatar': 'DC'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ARENA FRIEND ACTIVITY',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 14),
        ...activities.map((act) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: 14,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Text(
                        act['avatar'] as String,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${act['user']} ',
                            style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          TextSpan(
                            text: act['action'] as String,
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    act['time'] as String,
                    style: const TextStyle(color: AppColors.outline, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMemberBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, icon: Icons.home, label: 'Home', isActive: true, route: AppRoutes.memberHome),
            _buildNavItem(context, icon: Icons.emoji_events_outlined, label: 'Compete', route: AppRoutes.compete),
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Arena Ranks', route: AppRoutes.localGymLeaderboard),
            _buildNavItem(context, icon: Icons.person_outline, label: 'Profile', route: AppRoutes.memberProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, bool isActive = false, required String route}) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.onPrimary : AppColors.outline),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isActive ? AppColors.onPrimary : AppColors.outline,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
