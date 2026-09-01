/// Utility functions for streak-related calculations and formatting
class StreakUtils {
  /// Format streak count with appropriate suffix
  static String formatStreakCount(int days) {
    return '$days ${days == 1 ? 'day' : 'days'}';
  }

  /// Get streak achievement message based on count
  static String getStreakMessage(int currentStreak, int longestStreak) {
    if (currentStreak == 0) {
      return 'Start your streak today! 🔥';
    } else if (currentStreak < 3) {
      return 'Getting started! Keep it up! 💪';
    } else if (currentStreak < 7) {
      return 'Week one complete! Nice work! ⚡';
    } else if (currentStreak < 30) {
      return 'On fire! You\'re unstoppable! 🔥';
    } else if (currentStreak == longestStreak && currentStreak >= 30) {
      return 'New personal record! Amazing! 🏆';
    } else if (currentStreak > longestStreak) {
      return 'Beating your best! Keep going! 🚀';
    } else {
      return 'Crushing it! You\'ve got this! 💯';
    }
  }

  /// Get motivational message based on streak length
  static String getMotivationalMessage(int streak) {
    final messages = [
      'Start your journey today! 🚀',
      'One day in, keep going! 💪',
      'Two days strong! 🔥',
      'Three\'s a charm! ⭐',
      'A week of dedication! 🏅',
      'Two weeks of consistency! 💎',
      'Three weeks! You\'re legendary! 👑',
      'One month! Incredible! 🎯',
      'Forty days! Unstoppable! 🌟',
      'Fifty days! A true champion! 🏆',
      'Sixty days! Legendary status! 🔥',
      '100 days! You are a machine! 🤖',
      '365 days! One year! 🎉',
    ];

    if (streak == 0) return messages[0];
    if (streak <= messages.length - 1) return messages[streak];
    return 'You are absolutely legendary! 👑✨';
  }

  /// Calculate days remaining to reach next milestone
  static int daysToMilestone(int currentStreak) {
    final milestones = [1, 3, 7, 14, 30, 60, 100, 365];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone - currentStreak;
      }
    }
    
    return 0;
  }

  /// Get next milestone streak count
  static int getNextMilestone(int currentStreak) {
    final milestones = [1, 3, 7, 14, 30, 60, 100, 365];
    
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    
    return currentStreak + 100;
  }

  /// Determine streak status/tier
  static StreakTier getStreakTier(int currentStreak) {
    if (currentStreak == 0) return StreakTier.none;
    if (currentStreak < 3) return StreakTier.starter;
    if (currentStreak < 7) return StreakTier.beginner;
    if (currentStreak < 30) return StreakTier.intermediate;
    if (currentStreak < 100) return StreakTier.expert;
    return StreakTier.legendary;
  }

  /// Get color based on streak tier
  static int getTierColor(StreakTier tier) {
    switch (tier) {
      case StreakTier.none:
        return 0xFF4B4B4B;
      case StreakTier.starter:
        return 0xFF87CEEB;
      case StreakTier.beginner:
        return 0xFF90EE90;
      case StreakTier.intermediate:
        return 0xFFFFD700;
      case StreakTier.expert:
        return 0xFFFF8C00;
      case StreakTier.legendary:
        return 0xFFFF1493;
    }
  }

  /// Format date with smart comparison to today
  static String formatDateSmart(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Check if streak is active (has activity within last 24 hours)
  static bool isStreakActive(DateTime? lastStreakDate) {
    if (lastStreakDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastStreakDate);
    return diff.inHours < 24;
  }

  /// Check if streak will break tomorrow (no activity today)
  static bool willStreakBreakTomorrow(DateTime? lastStreakDate) {
    if (lastStreakDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastStreakDate);
    // If last activity was yesterday
    return diff.inDays >= 1 && diff.inDays < 2;
  }

  /// Calculate activity rate percentage
  static double calculateActivityRate(int totalWorkouts, DateTime? createdDate) {
    if (createdDate == null || totalWorkouts == 0) return 0.0;
    
    final daysSinceCreated = DateTime.now().difference(createdDate).inDays + 1;
    final rate = (totalWorkouts / daysSinceCreated) * 100;
    
    return rate > 100 ? 100.0 : rate;
  }

  /// Get activity frequency label
  static String getActivityFrequency(double activityRate) {
    if (activityRate == 0) return 'No activity';
    if (activityRate < 10) return 'Very low';
    if (activityRate < 25) return 'Low';
    if (activityRate < 50) return 'Moderate';
    if (activityRate < 80) return 'High';
    if (activityRate < 100) return 'Very high';
    return 'Daily';
  }

  /// Generate streak summary text
  static String generateStreakSummary(
    int currentStreak,
    int longestStreak,
    int totalWorkouts,
    DateTime? createdDate,
  ) {
    final activityRate = calculateActivityRate(totalWorkouts, createdDate);
    final tier = getStreakTier(currentStreak);
    final tierName = tier.toString().split('.').last;

    return '''
📊 Streak Summary
Current Streak: $currentStreak days
Longest Streak: $longestStreak days
Total Workouts: $totalWorkouts
Activity Rate: ${activityRate.toStringAsFixed(1)}%
Tier: ${tierName.toUpperCase()}

${getMotivationalMessage(currentStreak)}
''';
  }
}

/// Streak tier enum for progression tracking
enum StreakTier {
  none,
  starter,
  beginner,
  intermediate,
  expert,
  legendary,
}

/// Extension for tier descriptions
extension StreakTierExtension on StreakTier {
  String get description {
    switch (this) {
      case StreakTier.none:
        return 'No Streak';
      case StreakTier.starter:
        return 'Starter (1-2 days)';
      case StreakTier.beginner:
        return 'Beginner (3-6 days)';
      case StreakTier.intermediate:
        return 'Intermediate (7-29 days)';
      case StreakTier.expert:
        return 'Expert (30-99 days)';
      case StreakTier.legendary:
        return 'Legendary (100+ days)';
    }
  }

  String get emoji {
    switch (this) {
      case StreakTier.none:
        return '❌';
      case StreakTier.starter:
        return '🌱';
      case StreakTier.beginner:
        return '💪';
      case StreakTier.intermediate:
        return '🔥';
      case StreakTier.expert:
        return '⚡';
      case StreakTier.legendary:
        return '👑';
    }
  }
}
