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
  bool _isLogging = false;

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
      if (date == startOfToday) {
        return activityDates.contains(date) ? DayState.done : DayState.current;
      }
      return activityDates.contains(date) ? DayState.done : DayState.empty;
    });
  }

  Future<void> _logActivity() async {
    if (_isLogging) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.whatshot, color: Colors.orangeAccent, size: 26),
                const SizedBox(width: 10),
                const Text(
                  'LOG TODAY\'S STREAK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _HomePageState.muted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select completed activity to maintain your streak fire:',
              style: TextStyle(color: _HomePageState.muted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            const _ActivityOptionTile(
              icon: Icons.fitness_center,
              title: 'Gym & Strength Session',
              duration: '45-60 min • High XP',
            ),
            const SizedBox(height: 8),
            const _ActivityOptionTile(
              icon: Icons.directions_run,
              title: 'Outdoor Run / Cardio',
              duration: '30-45 min • High Calorie',
            ),
            const SizedBox(height: 8),
            const _ActivityOptionTile(
              icon: Icons.self_improvement,
              title: 'Mobility & Recovery',
              duration: '20-30 min • Active Rest',
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  setState(() => _isLogging = true);
                  try {
                    await _streakService.recordActivity(activityType: 'Workout');
                  } catch (_) {}
                  if (mounted) {
                    setState(() {
                      _isLogging = false;
                      _loadStreakData();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔥 Boom! Today\'s Activity Logged! Streak Extended!'),
                        backgroundColor: Color(0xFF2A2A2A),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.local_fire_department, color: Colors.black),
                label: const Text(
                  'CLAIM & LOG WORKOUT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _HomePageState.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
    future: _streakDataFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          height: 290,
          padding: const EdgeInsets.fromLTRB(24, 25, 20, 22),
          decoration: BoxDecoration(
            color: _HomePageState.surface,
            borderRadius: BorderRadius.circular(16),
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
              height: 290,
              padding: const EdgeInsets.fromLTRB(24, 22, 20, 22),
              decoration: BoxDecoration(
                color: _HomePageState.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF262626)),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Daily Streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252115),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _HomePageState.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🧊 1 Freeze',
                              style: TextStyle(
                                color: _HomePageState.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2513),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _HomePageState.gold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🔥 ',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${streakData.currentStreak} ${streakData.currentStreak == 1 ? 'Day' : 'Days'}',
                              style: const TextStyle(
                                color: _HomePageState.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🏆 Longest: ${streakData.longestStreak} Days',
                        style: const TextStyle(
                          color: _HomePageState.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '💪 Total: ${streakData.totalWorkouts} Workouts',
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.touch_app_outlined,
                          size: 14,
                          color: _HomePageState.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap card to log today\'s workout & extend streak',
                          style: TextStyle(
                            color: _HomePageState.muted.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _ActivityOptionTile extends StatelessWidget {
  const _ActivityOptionTile({
    required this.icon,
    required this.title,
    required this.duration,
  });

  final IconData icon;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2615),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _HomePageState.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    color: _HomePageState.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: _HomePageState.muted,
            size: 20,
          ),
        ],
      ),
    );
  }
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
          style: TextStyle(
            color: current ? _HomePageState.gold : _HomePageState.muted,
            fontSize: 12,
            fontWeight: current ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: current
                ? _HomePageState.gold
                : done
                ? const Color(0xFF3C361D)
                : const Color(0xFF141414),
            shape: BoxShape.circle,
            border: Border.all(
              color: current
                  ? _HomePageState.gold
                  : done
                  ? const Color(0xFF5E5224)
                  : const Color(0xFF242424),
              width: current ? 2 : 1,
            ),
            boxShadow: current
                ? const [BoxShadow(color: Color(0x88FFC83D), blurRadius: 10)]
                : null,
          ),
          child: done
              ? const Icon(Icons.check, color: _HomePageState.gold, size: 18)
              : current
              ? const Icon(Icons.local_fire_department, color: Colors.black, size: 18)
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

  @override
  void initState() {
    super.initState();
    _loadTodayPlanFromSupabase();
  }

  Future<void> _loadTodayPlanFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final todayStr = DateTime.now().toIso8601String().split('T').first;
        final response = await Supabase.instance.client
            .from('workout_sessions')
            .select()
            .eq('user_id', user.id)
            .gte('completed_at', '$todayStr T00:00:00')
            .limit(1);
        if (response.isNotEmpty) {
          setState(() {
            _isCompleted = true;
          });
        }
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  Future<void> _toggleWorkoutCompletion() async {
    setState(() => _isCompleted = !_isCompleted);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && _isCompleted) {
      try {
        await Supabase.instance.client.from('workout_sessions').insert({
          'user_id': user.id,
          'status': 'completed',
          'workout_name': 'Push Day',
          'completed_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Ignored for offline/fallback
      }
    }
  }

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
                  _toggleWorkoutCompletion();
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

class _StatsRow extends StatefulWidget {
  // Stats row section of the home page
  const _StatsRow();

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> {
  String _kcalValue = '620';
  String _volumeValue = '8.4k';
  String _xpValue = '+240';

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('xp, total_volume, calories_burned')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            if (response['calories_burned'] != null) {
              _kcalValue = '${response['calories_burned']}';
            }
            if (response['total_volume'] != null) {
              _volumeValue = '${response['total_volume']}k';
            }
            if (response['xp'] != null) {
              _xpValue = '+${response['xp']}';
            }
          });
        }
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  void _showStatDetails(BuildContext context, String type) {
    String title = '';
    String subtitle = '';
    IconData headerIcon = Icons.auto_graph;
    List<Widget> contentWidgets = [];

    if (type == 'KCAL') {
      title = 'CALORIES BURNED';
      subtitle = 'Daily Energy Expenditure';
      headerIcon = Icons.local_fire_department;
      contentWidgets = [
        _StatProgressTile(
          label: 'Daily Target Progress',
          value: '$_kcalValue / 750 kcal',
          progress: 0.82,
          color: Colors.orangeAccent,
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _DetailMetricCard(
                title: 'Active Workouts',
                value: '480 kcal',
                subtext: '55 min Push Session',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _DetailMetricCard(
                title: 'Resting & Steps',
                value: '140 kcal',
                subtext: '4,200 Steps',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '🔥 +14% higher calorie burn than last Friday!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (type == 'VOLUME') {
      title = 'WORKOUT VOLUME';
      subtitle = 'Total Weight Moved Today';
      headerIcon = Icons.fitness_center;
      contentWidgets = [
        _StatProgressTile(
          label: 'Target Volume Benchmark',
          value: '$_volumeValue kg',
          progress: 0.95,
          color: _HomePageState.gold,
        ),
        const SizedBox(height: 16),
        const Text(
          'Volume by Movement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const _VolumeBreakdownRow(exercise: 'Barbell Bench Press', weight: '3,400 kg', percent: '40%'),
        const _VolumeBreakdownRow(exercise: 'Overhead Press', weight: '2,800 kg', percent: '33%'),
        const _VolumeBreakdownRow(exercise: 'Dips & Cable Iso', weight: '2,200 kg', percent: '27%'),
      ];
    } else {
      title = 'EXPERIENCE (XP)';
      subtitle = 'Level & Rewards Progression';
      headerIcon = Icons.star;
      contentWidgets = [
        const _StatProgressTile(
          label: 'Level 14 → Level 15 Progress',
          value: '3,740 / 4,000 XP',
          progress: 0.935,
          color: _HomePageState.gold,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _HomePageState.gold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Today\'s Gain', style: TextStyle(color: _HomePageState.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(_xpValue, style: const TextStyle(color: _HomePageState.gold, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Streak Multiplier', style: TextStyle(color: _HomePageState.muted, fontSize: 11)),
                    SizedBox(height: 4),
                    Text('⚡ 1.5x Boost', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(headerIcon, color: _HomePageState.gold, size: 24),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _HomePageState.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _HomePageState.muted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Divider(color: Color(0xFF292929), height: 26),
            ...contentWidgets,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _Stat(
              icon: Icons.local_fire_department_outlined,
              value: _kcalValue,
              label: 'KCAL',
              trend: '↑ 14%',
              onTap: () => _showStatDetails(context, 'KCAL'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Stat(
              icon: Icons.fitness_center,
              value: _volumeValue,
              label: 'VOLUME\n(KG)',
              trend: '↑ 8%',
              onTap: () => _showStatDetails(context, 'VOLUME'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Stat(
              icon: Icons.star_border,
              value: _xpValue,
              label: 'XP',
              goldValue: true,
              trend: '⚡ 1.5x',
              highlightBorder: true,
              onTap: () => _showStatDetails(context, 'XP'),
            ),
          ),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.goldValue = false,
    this.trend,
    this.highlightBorder = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool goldValue;
  final String? trend;
  final bool highlightBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 138,
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
            decoration: BoxDecoration(
              color: _HomePageState.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: highlightBorder
                    ? _HomePageState.gold.withValues(alpha: 0.4)
                    : const Color(0xFF262626),
                width: highlightBorder ? 1.2 : 1.0,
              ),
              boxShadow: highlightBorder
                  ? [
                      BoxShadow(
                        color: _HomePageState.gold.withValues(alpha: 0.08),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                if (trend != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: goldValue
                            ? const Color(0xFF382F10)
                            : const Color(0xFF222C23),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trend!,
                        style: TextStyle(
                          color: goldValue
                              ? _HomePageState.gold
                              : const Color(0xFF8FF596),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: _HomePageState.gold, size: 22),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: goldValue ? _HomePageState.gold : Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
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
              ],
            ),
          ),
        ),
      );
}

class _StatProgressTile extends StatelessWidget {
  const _StatProgressTile({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _HomePageState.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFF282828),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _DetailMetricCard extends StatelessWidget {
  const _DetailMetricCard({
    required this.title,
    required this.value,
    required this.subtext,
  });

  final String title;
  final String value;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _HomePageState.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtext, style: const TextStyle(color: _HomePageState.muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _VolumeBreakdownRow extends StatelessWidget {
  const _VolumeBreakdownRow({
    required this.exercise,
    required this.weight,
    required this.percent,
  });

  final String exercise;
  final String weight;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              exercise,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            weight,
            style: const TextStyle(color: _HomePageState.gold, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF292929),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percent,
              style: const TextStyle(color: _HomePageState.muted, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatefulWidget {
  // Active challenge card section of the home page
  const _ChallengeCard();

  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  int _userReps = 72;
  final int _opponentReps = 64;
  final int _targetReps = 100;

  @override
  void initState() {
    super.initState();
    _loadChallengeFromSupabase();
  }

  Future<void> _loadChallengeFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('challenges')
            .select('user_reps')
            .eq('user_id', user.id)
            .maybeSingle();
        if (response != null && response['user_reps'] != null) {
          setState(() {
            _userReps = (response['user_reps'] as num).toInt();
          });
        }
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  Future<void> _syncRepsToSupabase(int newReps) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('challenges').upsert({
          'user_id': user.id,
          'challenge_name': '100 Push-ups vs Rahul',
          'user_reps': newReps,
          'opponent_reps': _opponentReps,
          'target_reps': _targetReps,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  void _showLogRepsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.emoji_events, color: _HomePageState.gold, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'LOG CHALLENGE REPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _HomePageState.muted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '100 Push-ups vs Rahul • Current: $_userReps / $_targetReps reps',
              style: const TextStyle(color: _HomePageState.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _RepIncrementBtn(
                  label: '+5 REPS',
                  onTap: () => _addReps(5, ctx),
                ),
                const SizedBox(width: 10),
                _RepIncrementBtn(
                  label: '+10 REPS',
                  onTap: () => _addReps(10, ctx),
                ),
                const SizedBox(width: 10),
                _RepIncrementBtn(
                  label: '+20 REPS',
                  onTap: () => _addReps(20, ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addReps(int count, BuildContext ctx) {
    Navigator.of(ctx).pop();
    final newReps = (_userReps + count).clamp(0, _targetReps);
    setState(() {
      _userReps = newReps;
    });
    _syncRepsToSupabase(newReps);
    final isWon = _userReps >= _targetReps;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWon
              ? '🏆 CONGRATS! You completed 100 Push-ups and WON the challenge vs Rahul!'
              : '⚡ Added +$count reps! You now have $_userReps / $_targetReps reps.',
        ),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diff = _userReps - _opponentReps;
    final progress = (_userReps / _targetReps).clamp(0.0, 1.0);
    final remaining = _targetReps - _userReps;
    final isWon = _userReps >= _targetReps;

    return Container(
      padding: const EdgeInsets.fromLTRB(23, 22, 23, 22),
      decoration: BoxDecoration(
        color: _HomePageState.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWon
              ? _HomePageState.gold
              : const Color(0xFF2B2B2B),
          width: isWon ? 1.5 : 1.0,
        ),
        boxShadow: isWon
            ? [
                BoxShadow(
                  color: _HomePageState.gold.withValues(alpha: 0.12),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                color: _HomePageState.gold,
                size: 18,
              ),
              const SizedBox(width: 7),
              const Text(
                'Active Challenge',
                style: TextStyle(
                  color: _HomePageState.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isWon
                      ? const Color(0xFF1E5B22)
                      : const Color(0xFF2B2412),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isWon
                        ? Colors.green
                        : _HomePageState.gold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isWon
                      ? '🏆 VICTORY'
                      : diff > 0
                          ? '👑 LEADING BY $diff'
                          : '⚡ TIED',
                  style: TextStyle(
                    color: isWon
                        ? const Color(0xFF8FF596)
                        : _HomePageState.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '100 Push-ups',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Text(
                          'vs ',
                          style: TextStyle(
                            color: _HomePageState.muted,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Rahul',
                          style: TextStyle(
                            color: _HomePageState.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '• ⏳ 4h left',
                          style: TextStyle(
                            color: _HomePageState.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '$_userReps',
                style: const TextStyle(
                  color: _HomePageState.gold,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ' vs $_opponentReps',
                  style: const TextStyle(
                    color: _HomePageState.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFF28251C),
              valueColor: AlwaysStoppedAnimation(
                isWon ? Colors.greenAccent : _HomePageState.gold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isWon ? '100% Completed!' : '$remaining reps remaining',
                style: TextStyle(
                  color: isWon ? const Color(0xFF8FF596) : _HomePageState.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: _showLogRepsModal,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2615),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _HomePageState.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: _HomePageState.gold, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'LOG REPS',
                        style: TextStyle(
                          color: _HomePageState.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
}

class _RepIncrementBtn extends StatelessWidget {
  const _RepIncrementBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: _HomePageState.gold.withValues(alpha: 0.3)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _HomePageState.gold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FriendsSection extends StatefulWidget {
  // Friends training now section of the home page
  const _FriendsSection();

  @override
  State<_FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<_FriendsSection> {
  List<Map<String, String>> _friends = [
    {
      'name': 'Rahul',
      'workout': 'Leg Day',
      'duration': '38m',
      'detail': 'Set 4 of 6 • Heavy Barbell Squats',
      'url': 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=100&q=80',
    },
    {
      'name': 'Arjun',
      'workout': 'Cardio Run',
      'duration': '24m',
      'detail': '3.8 km completed • Pace: 4:55 /km',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
    },
    {
      'name': 'Sneha',
      'workout': 'Upper Body',
      'duration': '15m',
      'detail': 'Set 2 of 5 • Dumbbell Shoulder Press',
      'url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFriendsFromSupabase();
  }

  Future<void> _loadFriendsFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('friends')
            .select()
            .eq('user_id', user.id)
            .eq('is_training', true);
        setState(() {
          _friends = List<Map<String, String>>.from(
            response.map((f) => {
                  'name': (f['name'] ?? 'Friend').toString(),
                  'workout': (f['workout'] ?? 'Workout').toString(),
                  'duration': (f['duration'] ?? 'Live').toString(),
                  'detail': (f['detail'] ?? 'Active Session').toString(),
                  'url': (f['avatar_url'] ??
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80')
                      .toString(),
                }),
          );
        });
      } catch (_) {
        // Fallback gracefully
      }
    }
  }

  void _showFriendCheerModal(
    BuildContext context,
    String name,
    String workout,
    String detail,
    String duration,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF19D65A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x9919D65A),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$name IS TRAINING NOW',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _HomePageState.muted),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: _HomePageState.gold,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout,
                          style: const TextStyle(
                            color: _HomePageState.gold,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF292929),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⏱ $duration',
                      style: const TextStyle(
                        color: _HomePageState.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Send Live Cheer & Encouragement:',
              style: TextStyle(
                color: _HomePageState.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _CheerBtn(
                  emoji: '🔥',
                  label: 'High Five',
                  onTap: () => _sendCheer(context, ctx, name, '🔥 High Five'),
                ),
                const SizedBox(width: 8),
                _CheerBtn(
                  emoji: '💪',
                  label: 'Push Hard',
                  onTap: () => _sendCheer(context, ctx, name, '💪 Push Hard'),
                ),
                const SizedBox(width: 8),
                _CheerBtn(
                  emoji: '⚡',
                  label: 'Rival Boost',
                  onTap: () => _sendCheer(context, ctx, name, '⚡ Rival Boost'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _sendCheer(
    BuildContext context,
    BuildContext modalCtx,
    String name,
    String cheerType,
  ) {
    Navigator.of(modalCtx).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Sent $cheerType to $name!'),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _friends.isNotEmpty
                      ? const Color(0xFF1E3A20)
                      : const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _friends.isNotEmpty
                        ? const Color(0xFF2E6332)
                        : const Color(0xFF383838),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _friends.isNotEmpty
                            ? const Color(0xFF19D65A)
                            : _HomePageState.muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_friends.length} LIVE',
                      style: TextStyle(
                        color: _friends.isNotEmpty
                            ? const Color(0xFF8FF596)
                            : _HomePageState.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_friends.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _HomePageState.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF262626)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.people_outline, color: _HomePageState.muted, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Friends Training Live',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Invite friends to train together & track live workouts!',
                          style: TextStyle(
                            color: _HomePageState.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _friends.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return SizedBox(
                    width: 165,
                    child: _FriendCard(
                      name: friend['name']!,
                      workout: friend['workout']!,
                      duration: friend['duration'] ?? 'Live',
                      url: friend['url']!,
                      onTap: () => _showFriendCheerModal(
                        context,
                        friend['name']!,
                        friend['workout']!,
                        friend['detail'] ?? 'Active Workout Session',
                        friend['duration'] ?? 'Live',
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
}

class _CheerBtn extends StatelessWidget {
  const _CheerBtn({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: _HomePageState.gold.withValues(alpha: 0.3)),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: _HomePageState.gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.name,
    required this.workout,
    required this.duration,
    required this.url,
    this.onTap,
  });

  final String name;
  final String workout;
  final String duration;
  final String url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _HomePageState.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF262626)),
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
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF19D65A),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _HomePageState.surface, width: 1.5),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: _HomePageState.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        workout,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _HomePageState.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
