// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile/Profile_page.dart';
import '../../services/streak_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;
  String _UserName = 'Wasim';
  String _avatarUrl = '';
  int _notificationCount = 2;

  static const gold = Color(0xFFFFC83D); // Gold color used in the UI
  static const background = Color(
    0xFF101010,
  ); // Background color for the home page
  static const surface = Color(
    0xFF191919,
  ); // Surface color for cards and containers
  static const muted = Color(
    0xFFB9B3A8,
  ); // Muted color for less prominent text and icons

  @override
  void initState() {
    super.initState();
    _LoadUserProfile(); // Load user profile data when the home page is initialized
  }

  Future<void> _LoadUserProfile() async {
    // Load user profile data from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        setState(() {
          _UserName = response['full_name'] ?? 'Rivals User';
          _avatarUrl = response['avatar_url'] ?? '';
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the home page UI
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: _BottomBar(
        selectedIndex: _selectedTab,
        onSelected: (value) {
          setState(() => _selectedTab = value);

          if (value == 4) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            28,
            18,
            18,
          ), // Padding for the content inside the ListView
          children: [
            _Header(
              greeting: 'Good Morning',
              userName: _UserName,
              avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
              onNotificationTap: null,
              onNotificationCount: null,
              notificationCount: 0,
            ),
            SizedBox(height: 38),
            _StreakCard(), //Space between the streak card and the next section

            SizedBox(height: 16),
            _TodayPlan(), //Space between the today's plan and the next section

            SizedBox(height: 28),
            _StatsRow(), //Space between the stats row and the next section

            SizedBox(height: 30), _ChallengeCard(), //Space between the challenge card and the next section

            SizedBox(height: 32), _FriendsSection(), //Space between the friends section and the next section
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String userName;
  final String avatarUrl;
  final VoidCallback? onNotificationCount;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  // Header section of the home page
  const _Header({
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.onNotificationTap,
    required this.onNotificationCount,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const _Photo(
        url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
        size: 50,
      ), // User profile photo with a circular shape
      const SizedBox(width: 10), // Space between the photo and the text
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getUserName(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ), // Greeting text
            const SizedBox(height: 3),
            const Text(
              'Ready to beat yesterday?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ), // Subtext below the greeting
          ],
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.notifications_none,
          color: _HomePageState.muted,
          size: 25,
        ),
      ),
    ],
  );

  String _getUserName() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, $userName';
    if (hour < 17) return 'Good Afternoon, $userName';
    return 'Good Evening, $userName';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('notificationCount', notificationCount));
  }
}

class _StreakCard extends StatefulWidget {
  // Streak card section of the home page
  const _StreakCard();

  @override
  State<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<_StreakCard> {
  late Future<dynamic> _streakDataFuture;
  late Future<List<DayState>> _dayStatesFuture;
  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  void _loadStreakData() {
    _streakDataFuture = _streakService.getStreak();
    _dayStatesFuture = _loadWeekDayStates();
  }

  Future<List<DayState>> _loadWeekDayStates() async {
    final streakData = await _streakService.getStreak();
    final activityDates = ((streakData as dynamic).recentActivityDates as Iterable?)
            ?.map((date) => date is DateTime ? date : DateTime.parse(date.toString()))
            .toSet() ??
        <DateTime>{};
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return List.generate(7, (index) {
      final date = startOfToday.subtract(Duration(days: 6 - index));
      if (date == startOfToday) return DayState.current;
      return activityDates.contains(date) ? DayState.done : DayState.empty;
    });
  }

  Future<void> _logActivity() async {
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
    future: _streakDataFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: 300,
          padding: const EdgeInsets.fromLTRB(24, 25, 20, 22),
          decoration: BoxDecoration(
            color: _HomePageState.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: _HomePageState.gold),
          ),
        );
      }

      final streakData =
          snapshot.data ??
          _StreakDataFallback(
            currentStreak: 0,
            longestStreak: 0,
            totalWorkouts: 0,
            recentActivityDates: [],
          );

      return FutureBuilder<List<DayState>>(
        future: _dayStatesFuture,
        builder: (context, dayStatesSnapshot) {
          final dayStates =
              dayStatesSnapshot.data ?? List.filled(7, DayState.empty);
          final dayLabels = _streakService.getWeekDayLabels();

          return GestureDetector(
            onTap: _logActivity,
            child: Container(
              height: 300,
              padding: const EdgeInsets.fromLTRB(24, 25, 20, 22),
              decoration: BoxDecoration(
                color: _HomePageState.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Daily Streak',
                        style: TextStyle(
                          color: _HomePageState.muted,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF292929),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          '${streakData.currentStreak} ${streakData.currentStreak == 1 ? 'Day' : 'Days'}',
                          style: const TextStyle(
                            color: _HomePageState.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Longest: ${streakData.longestStreak}',
                        style: const TextStyle(
                          color: _HomePageState.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total: ${streakData.totalWorkouts}',
                        style: const TextStyle(
                          color: _HomePageState.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (index) => _Day(
                        label: dayLabels[index],
                        state: dayStates[index],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Tap to log today\'s workout',
                      style: TextStyle(
                        color: _HomePageState.muted.withOpacity(0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _StreakDataFallback {
  const _StreakDataFallback({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
    required this.recentActivityDates,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final List<dynamic> recentActivityDates;
}

enum DayState { empty, current, done }

class _Day extends StatelessWidget {
  const _Day({required this.label, required this.state});
  final String label;
  final DayState state;

  @override
  Widget build(BuildContext context) {
    final current = state == DayState.current;
    final done = state == DayState.done;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _HomePageState.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: current
                ? _HomePageState.gold
                : done
                ? const Color(0xFF3C361D)
                : const Color(0xFF111111),
            shape: BoxShape.circle,
            boxShadow: current
                ? const [BoxShadow(color: Color(0x66FFC83D), blurRadius: 8)]
                : null,
          ),
          child: done
              ? const Icon(Icons.check, color: _HomePageState.gold, size: 17)
              : null,
        ),
      ],
    );
  }
}

class _TodayPlan extends StatefulWidget {
  // Today's plan section of the home page
  const _TodayPlan();

  @override
  State<_TodayPlan> createState() => _TodayPlanState();
}

class _TodayPlanState extends State<_TodayPlan> {
  bool _isExpanded = false;
  bool _isCompleted = false;

  final List<Map<String, String>> _exercises = const [
    {'name': 'Barbell Bench Press', 'detail': '4 sets × 8-10 reps'},
    {'name': 'Incline Dumbbell Press', 'detail': '3 sets × 10-12 reps'},
    {'name': 'Overhead Shoulder Press', 'detail': '4 sets × 8 reps'},
    {'name': 'Cable Lateral Raises', 'detail': '3 sets × 12-15 reps'},
    {'name': 'Tricep Rope Pushdowns', 'detail': '4 sets × 12 reps'},
    {'name': 'Parallel Bar Dips', 'detail': '3 sets to failure'},
    {'name': 'Chest Flyes', 'detail': '3 sets × 12 reps'},
  ];

  void _showWorkoutDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PUSH DAY WORKOUT',
                    style: TextStyle(
                      color: _HomePageState.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: _HomePageState.muted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Focus: Chest, Shoulders, Triceps • 7 Exercises • 55 min',
                style: TextStyle(color: _HomePageState.muted, fontSize: 13),
              ),
              const Divider(color: Color(0xFF292929), height: 30),
              ...List.generate(_exercises.length, (index) {
                final ex = _exercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _HomePageState.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: _HomePageState.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ex['detail']!,
                              style: const TextStyle(
                                color: _HomePageState.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_outline,
                        color: _HomePageState.muted,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _isCompleted = !_isCompleted);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isCompleted
                            ? '🎉 Push Day marked as Completed!'
                            : 'Workout reset to ready state.',
                      ),
                      backgroundColor: const Color(0xFF2A2A2A),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _HomePageState.gold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isCompleted ? 'MARK AS INCOMPLETE' : 'START WORKOUT NOW',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: _HomePageState.gold,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x28FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⚒  TODAY\'S PLAN',
                      style: TextStyle(
                        color: Color(0xFF4B3900),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? const Color(0xFF1E5B22)
                      : const Color(0xFF493500),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isCompleted ? '✓ COMPLETED' : 'READY',
                  style: TextStyle(
                    color: _isCompleted
                        ? const Color(0xFF8FF596)
                        : _HomePageState.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Workout Title & Muscle Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCompleted ? 'PUSH DAY (DONE)' : 'PUSH DAY',
                      style: const TextStyle(
                        color: Color(0xFF352700),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chest, Shoulders & Triceps',
                      style: TextStyle(
                        color: Color(0xFF5B4600),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _isCompleted = !_isCompleted);
                },
                tooltip: 'Toggle completed state',
                icon: Icon(
                  _isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: const Color(0xFF493500),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Muscle Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              _MuscleChip(label: 'Chest'),
              _MuscleChip(label: 'Shoulders'),
              _MuscleChip(label: 'Triceps'),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Pills Row
          Row(
            children: [
              const Expanded(
                child: _PlanPill(icon: Icons.access_time, label: '55 min'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _PlanPill(
                  icon: Icons.format_list_bulleted,
                  label: '7 Exercises',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _PlanPill(
                  icon: Icons.local_fire_department_outlined,
                  label: '~450 kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Expandable Exercise Preview Toggle
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x18493500),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Color(0xFF493500),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Workout Breakdown',
                    style: TextStyle(
                      color: Color(0xFF493500),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF493500),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Exercise Items
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x15000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: List.generate(_exercises.length, (index) {
                  final ex = _exercises[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF493500),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: _HomePageState.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex['name']!,
                            style: const TextStyle(
                              color: Color(0xFF352700),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          ex['detail']!,
                          style: const TextStyle(
                            color: Color(0xFF5B4600),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 22),

          // Start / Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _showWorkoutDetailsModal(context),
              icon: Icon(
                _isCompleted ? Icons.replay : Icons.play_arrow_rounded,
                color: _HomePageState.gold,
                size: 22,
              ),
              label: Text(
                _isCompleted ? 'VIEW / EDIT WORKOUT' : 'START WORKOUT  →',
                style: const TextStyle(
                  color: _HomePageState.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF493500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x22493500),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x33493500)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF493500),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlanPill extends StatelessWidget {
  // Plan pill widget used in the today's plan section
  const _PlanPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0x1E8A6800),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF493500), size: 17),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF493500),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _StatsRow extends StatelessWidget {
  // Stats row section of the home page
  const _StatsRow();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      // Row containing three stats: KCAL, VOLUME (KG), and XP
      Expanded(
        child: _Stat(
          icon: Icons.local_fire_department_outlined,
          value: '620',
          label: 'KCAL',
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: _Stat(
          icon: Icons.shopping_bag_outlined,
          value: '8.4k',
          label: 'VOLUME\n(KG)',
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: _Stat(
          icon: Icons.star_border,
          value: '+240',
          label: 'XP',
          goldValue: true,
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  // Individual stat widget used in the stats row section
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.goldValue = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool goldValue;

  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    padding: const EdgeInsets.only(top: 18),
    decoration: BoxDecoration(
      color: _HomePageState.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Icon(icon, color: _HomePageState.gold, size: 22),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: goldValue ? _HomePageState.gold : Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _HomePageState.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ],
    ),
  );
}

class _ChallengeCard extends StatelessWidget {
  // Active challenge card section of the home page
  const _ChallengeCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(23, 24, 23, 22),
    decoration: BoxDecoration(
      color: _HomePageState.surface,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.fitness_center, color: _HomePageState.muted, size: 15),
            SizedBox(width: 7),
            Text(
              'Active Challenge',
              style: TextStyle(
                color: _HomePageState.muted,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 23),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '100 Push-ups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'vs Rahul',
                    style: TextStyle(
                      color: _HomePageState.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '72',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                ' vs 64',
                style: TextStyle(
                  color: _HomePageState.muted,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: .72,
            minHeight: 13,
            backgroundColor: Color(0xFF302E29),
            valueColor: AlwaysStoppedAnimation(_HomePageState.gold),
          ),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '28 reps remaining',
            style: TextStyle(color: _HomePageState.muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _FriendsSection extends StatelessWidget {
  // Friends training now section of the home page
  const _FriendsSection();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          'Friends Training Now',
          style: TextStyle(
            color: _HomePageState.muted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 17),
      Row(
        children: const [
          Expanded(
            child: _FriendCard(
              name: 'Rahul',
              workout: 'Leg Day',
              url: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=100&q=80',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _FriendCard(
              name: 'Arjun',
              workout: 'Cardio',
              url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
            ),
          ),
        ],
      ),
    ],
  );
}

class _FriendCard extends StatelessWidget {
  // Individual friend card widget used in the friends training now section
  const _FriendCard({
    required this.name,
    required this.workout,
    required this.url,
  });
  final String name;
  final String workout;
  final String url;

  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _HomePageState.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Stack(
          children: [
            _Photo(url: url, size: 36),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF19D65A),
                  shape: BoxShape.circle,
                  border: Border.all(color: _HomePageState.surface, width: 1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                workout,
                style: const TextStyle(
                  color: _HomePageState.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Photo extends StatelessWidget {
  // Circular photo widget used for user profile and friend cards
  const _Photo({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: _HomePageState.gold,
        width: size > 40 ? 1.5 : 0,
      ),
      color: const Color(0xFF383838),
    ),
    child: ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Icon(Icons.person, color: _HomePageState.gold, size: size * .48),
      ),
    ),
  );
}

class _BottomBar extends StatelessWidget {
  // Bottom navigation bar section of the home page
  const _BottomBar({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    padding: const EdgeInsets.symmetric(horizontal: 9),
    decoration: const BoxDecoration(
      color: Color(0xFF151515),
      border: Border(top: BorderSide(color: Color(0xFF242424))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _NavItem(
          icon: Icons.home,
          label: 'Home',
          selected: selectedIndex == 0,
          onTap: () => onSelected(0),
        ),
        _NavItem(
          icon: Icons.bar_chart,
          label: 'Ranks',
          selected: selectedIndex == 1,
          onTap: () => onSelected(1),
        ),
        GestureDetector(
          onTap: () => onSelected(2),
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _HomePageState.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Colors.black, size: 31),
          ),
        ),
        _NavItem(
          icon: Icons.fitness_center,
          label: 'Workout',
          selected: selectedIndex == 3,
          onTap: () => onSelected(3),
        ),
        _NavItem(
          icon: Icons.person_outline,
          label: 'Profile',
          selected: selectedIndex == 4,
          onTap: () => onSelected(4),
        ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  // Individual navigation item widget used in the bottom navigation bar section
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? _HomePageState.gold : _HomePageState.muted,
            size: 21,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: selected ? _HomePageState.gold : _HomePageState.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}
