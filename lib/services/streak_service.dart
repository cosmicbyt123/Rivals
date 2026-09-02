import 'package:supabase_flutter/supabase_flutter.dart';


enum DayState {
  empty,
  current,
  done,
}
class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final int workoutsThisWeek;

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
    required this.workoutsThisWeek,
  });
}

class StreakService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<StreakStats> getStreakStats(String userId) async {
    final response = await _supabase
        .from('workout_sessions')
        .select('completed_at')
        .eq('user_id', userId)
        .eq('status', 'completed')
        .not('completed_at', 'is', null)
        .order('completed_at', ascending: true);

    final data = List<Map<String, dynamic>>.from(response);

    // Convert sessions into unique workout dates.
    final workoutDates = <DateTime>{};

    for (final session in data) {
      final completedAt = session['completed_at'];

      if (completedAt == null) continue;

      final date = DateTime.parse(completedAt.toString()).toLocal();

      workoutDates.add(
        DateTime(date.year, date.month, date.day),
      );
    }

    final sortedDates = workoutDates.toList()..sort();

    final currentStreak = _calculateCurrentStreak(sortedDates);
    final longestStreak = _calculateLongestStreak(sortedDates);

    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);

    final workoutsThisWeek = sortedDates.where((date) {
      return !date.isBefore(startOfWeek) &&
          date.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).length;

    return StreakStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalWorkouts: sortedDates.length,
      workoutsThisWeek: workoutsThisWeek,
    );
  }

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());
    final yesterday = _dateOnly(today.subtract(const Duration(days: 1)));

    // Streak must include today or yesterday.
    final lastDate = dates.last;

    if (!_isSameDate(lastDate, today) && !_isSameDate(lastDate, yesterday)) {
      return 0;
    }

    int streak = 1;

    for (int i = dates.length - 1; i > 0; i--) {
      if (_isConsecutiveDate(dates[i - 1], dates[i])) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      if (_isConsecutiveDate(dates[i - 1], dates[i])) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  DateTime _startOfWeek(DateTime date) {
    final dayOnly = _dateOnly(date);

    // Monday = 1, Sunday = 7
    return dayOnly.subtract(
      Duration(days: dayOnly.weekday - 1),
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isConsecutiveDate(DateTime previous, DateTime current) {
    final expected = DateTime(previous.year, previous.month, previous.day + 1);
    return _isSameDate(expected, current);
  }

  List<String> getWeekDayLabels() {
    return [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
  }

  Future<Object?> recordActivity({required String activityType}) async {
    // Simulate an API call to record the activity
    await Future.delayed(const Duration(milliseconds: 500));
    return {'activityType': activityType};
    
  }

  Future<Object?> getStreak() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }

}