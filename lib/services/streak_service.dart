import 'package:supabase_flutter/supabase_flutter.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStreakDate;
  final int totalWorkouts;
  final List<DateTime> recentActivityDates;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStreakDate,
    required this.totalWorkouts,
    required this.recentActivityDates,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastStreakDate: json['last_streak_date'] != null 
          ? DateTime.parse(json['last_streak_date'] as String)
          : null,
      totalWorkouts: json['total_workouts'] ?? 0,
      recentActivityDates: [],
    );
  }
}

class StreakService {
  static final StreakService _instance = StreakService._internal();

  factory StreakService() {
    return _instance;
  }

  StreakService._internal();

  final _supabase = Supabase.instance.client;

  /// Get streak data for the current user
  Future<StreakData> getUserStreakData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Fetch recent activity dates
      final activities = await _supabase
          .from('activity_log')
          .select()
          .eq('user_id', user.id)
          .gte('activity_date', DateTime.now().subtract(Duration(days: 6)).toIso8601String())
          .order('activity_date', ascending: false);

      final recentDates = (activities as List)
          .map((e) => DateTime.parse(e['activity_date'] as String))
          .toList();

      final streakData = StreakData.fromJson(response);
      return StreakData(
        currentStreak: streakData.currentStreak,
        longestStreak: streakData.longestStreak,
        lastStreakDate: streakData.lastStreakDate,
        totalWorkouts: streakData.totalWorkouts,
        recentActivityDates: recentDates,
      );
    } catch (e) {
      print('Error getting streak data: $e');
      return StreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalWorkouts: 0,
        recentActivityDates: [],
      );
    }
  }

  /// Log activity for today
  Future<bool> logActivity({String activityType = 'workout'}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('activity_log').upsert(
        {
          'user_id': user.id,
          'activity_type': activityType,
          'activity_date': DateTime.now().toIso8601String().split('T')[0],
        },
        onConflict: 'user_id,activity_date',
      );

      return true;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }

  /// Check if user has activity today
  Future<bool> hasActivityToday() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('activity_log')
          .select()
          .eq('user_id', user.id)
          .eq('activity_date', today);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking activity: $e');
      return false;
    }
  }

  /// Get day states for the current week
  Future<List<DayState>> getWeekDayStates() async {
    try {
      final streakData = await getUserStreakData();
      final today = DateTime.now();
      final List<DayState> dayStates = [];

      // Get Monday of current week
      final monday = today.subtract(Duration(days: today.weekday - 1));

      for (int i = 0; i < 7; i++) {
        final date = monday.add(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        
        if (date.isAfter(today)) {
          dayStates.add(DayState.empty);
        } else if (date.day == today.day && 
                   date.month == today.month && 
                   date.year == today.year) {
          // Check if today's activity is logged
          final hasToday = streakData.recentActivityDates.any((d) =>
              d.day == today.day && d.month == today.month && d.year == today.year);
          dayStates.add(hasToday ? DayState.current : DayState.empty);
        } else {
          final hasActivity = streakData.recentActivityDates.any((d) =>
              d.day == date.day && d.month == date.month && d.year == date.year);
          dayStates.add(hasActivity ? DayState.done : DayState.empty);
        }
      }

      return dayStates;
    } catch (e) {
      print('Error getting week day states: $e');
      return List.filled(7, DayState.empty);
    }
  }

  /// Get day labels for the current week
  List<String> getWeekDayLabels() {
    return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  }

  /// Recalculate streak (useful for midnight transitions)
  Future<StreakData> recalculateStreak() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Fetch all activity logs
      final activities = await _supabase
          .from('activity_log')
          .select()
          .eq('user_id', user.id)
          .order('activity_date', ascending: false);

      if ((activities as List).isEmpty) {
        return StreakData(
          currentStreak: 0,
          longestStreak: 0,
          totalWorkouts: 0,
          recentActivityDates: [],
        );
      }

      // Calculate streaks from activity dates
      final dates = (activities as List)
          .map((e) => DateTime.parse(e['activity_date'] as String))
          .toList();

      int currentStreak = 0;
      int longestStreak = 0;
      DateTime? lastDate;

      for (final date in dates) {
        if (lastDate == null) {
          currentStreak = 1;
          longestStreak = 1;
          lastDate = date;
        } else {
          final daysDiff = lastDate.difference(date).inDays;
          if (daysDiff == 1) {
            currentStreak++;
            if (currentStreak > longestStreak) {
              longestStreak = currentStreak;
            }
          } else if (daysDiff > 1) {
            break; // Streak is broken
          }
          lastDate = date;
        }
      }

      // Update in database
      await _supabase.from('profiles').update({
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_streak_date': DateTime.now(),
      }).eq('id', user.id);

      return StreakData(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalWorkouts: dates.length,
        recentActivityDates: dates,
      );
    } catch (e) {
      print('Error recalculating streak: $e');
      return await getUserStreakData();
    }
  }
}

enum DayState { done, current, empty }
