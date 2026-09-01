# Streak Functionality Documentation

## Overview

The Rivals app now includes comprehensive streak tracking functionality that monitors user activity and maintains streak counts. This system automatically tracks daily workouts and manages streak calculations.

## Features Implemented

### 1. **Database Schema Updates** (`supabase/profiles.sql`)

Added the following columns to the `profiles` table:
- `current_streak` (integer): Current consecutive days streak
- `longest_streak` (integer): Personal best streak record
- `last_streak_date` (timestamp): When the streak was last updated
- `total_workouts` (integer): Total number of logged workouts
- `streak_activity_dates` (text array): Array of activity dates

#### New Tables

**`activity_log`** - Tracks all user activities
```sql
- id (uuid): Primary key
- user_id (uuid): Reference to auth user
- activity_type (text): Type of activity (default: 'workout')
- activity_date (date): Date of activity
- created_at (timestamp): When logged
```

#### Automatic Streak Calculation

The database includes a trigger function `update_streak_on_activity()` that:
- Automatically updates streak counts when activities are logged
- Detects consecutive days
- Resets streak if a day is missed
- Updates longest streak if current exceeds it
- Increments total workout count

### 2. **Streak Service** (`lib/services/streak_service.dart`)

Core service class providing all streak-related functionality:

#### Key Methods

```dart
// Get user's current streak data
Future<StreakData> getUserStreakData()

// Log a new activity for today
Future<bool> logActivity({String activityType = 'workout'})

// Check if user has activity today
Future<bool> hasActivityToday()

// Get day states for current week (done, current, empty)
Future<List<DayState>> getWeekDayStates()

// Get week day labels (M, T, W, T, F, S, S)
List<String> getWeekDayLabels()

// Recalculate streak from all activities
Future<StreakData> recalculateStreak()
```

#### StreakData Model

```dart
class StreakData {
  final int currentStreak;          // Current consecutive days
  final int longestStreak;          // Personal best
  final DateTime? lastStreakDate;   // Last update
  final int totalWorkouts;          // Total activities
  final List<DateTime> recentActivityDates;  // Recent activities
}
```

#### DayState Enum

```dart
enum DayState { 
  done,      // Past day with activity
  current,   // Today
  empty      // Day without activity
}
```

### 3. **Updated Home Page** (`lib/Screens/home/home_page.dart`)

The streak card is now **stateful and dynamic**:

**Features:**
- Displays current streak count
- Shows longest streak achievement
- Displays total workouts
- Visualizes week with day states (M-S)
- Tap the card to log today's workout
- Real-time updates via Supabase
- Loading states while fetching data
- Helpful hint text

**UI Elements:**
- Gold badge showing current streak days
- Weekly grid showing activity status
- Stats row showing longest streak and total workouts
- Tap-to-log interaction

### 4. **Streak Statistics Widget** (`lib/widgets/streak_stats_widget.dart`)

Reusable widgets for displaying streak information:

#### `StreakStatsWidget`
Full stats display showing:
- Current streak with fire icon
- Longest streak with trending icon
- Total workouts with fitness icon
- Last activity date formatted intelligently

**Usage:**
```dart
StreakStatsWidget(
  userId: currentUser.id,
  primaryColor: Color(0xFFFFC83D),  // Optional
  backgroundColor: Color(0xFF101010),  // Optional
  surfaceColor: Color(0xFF191919),   // Optional
  mutedColor: Color(0xFFB9B3A8),     // Optional
)
```

#### `CompactStreakCard`
Minimal card display for dashboards:
- Current streak prominently displayed
- Personal best shown on the right
- Tap-enabled for navigation

**Usage:**
```dart
CompactStreakCard(
  primaryColor: Color(0xFFFFC83D),
  surfaceColor: Color(0xFF191919),
  mutedColor: Color(0xFFB9B3A8),
  onTap: () {
    // Handle tap
  },
)
```

## How to Use

### 1. **Initialize Streak Service**

```dart
final streakService = StreakService();
```

### 2. **Log a Workout**

```dart
// Log today's workout
final success = await streakService.logActivity(
  activityType: 'workout'
);

if (success) {
  print('Workout logged!');
}
```

### 3. **Get Streak Data**

```dart
final streakData = await streakService.getUserStreakData();

print('Current streak: ${streakData.currentStreak}');
print('Longest streak: ${streakData.longestStreak}');
print('Total workouts: ${streakData.totalWorkouts}');
```

### 4. **Check Today's Activity**

```dart
final hasToday = await streakService.hasActivityToday();

if (!hasToday) {
  print('Log a workout to keep your streak!');
}
```

### 5. **Get Week Day States**

```dart
final dayStates = await streakService.getWeekDayStates();

for (int i = 0; i < dayStates.length; i++) {
  if (dayStates[i] == DayState.done) {
    print('Day ${i + 1}: Completed ✓');
  }
}
```

## Integration Examples

### Example 1: Add Streak to Profile Page

```dart
import 'package:rivals/widgets/streak_stats_widget.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // ... other widgets
          StreakStatsWidget(
            userId: currentUser.id,
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Show Compact Streak in App Bar

```dart
AppBar(
  title: CompactStreakCard(
    onTap: () => Navigator.pushNamed(context, '/streak-details'),
  ),
)
```

### Example 3: Workout Completion Button

```dart
ElevatedButton(
  onPressed: () async {
    final success = await StreakService().logActivity();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Great job! 🔥')),
      );
    }
  },
  child: Text('Complete Workout'),
)
```

## Database Query Examples

### View a User's Streak Data

```sql
SELECT id, email, current_streak, longest_streak, total_workouts, last_streak_date
FROM profiles
WHERE id = '<user_id>';
```

### Get User's Activity Log

```sql
SELECT activity_date, activity_type
FROM activity_log
WHERE user_id = '<user_id>'
ORDER BY activity_date DESC
LIMIT 30;
```

### Find Most Consistent Users

```sql
SELECT email, current_streak, longest_streak, total_workouts
FROM profiles
WHERE total_workouts > 0
ORDER BY longest_streak DESC
LIMIT 10;
```

### Check Streaks Ending Today

```sql
SELECT email, current_streak, last_streak_date
FROM profiles
WHERE DATE(last_streak_date) = CURRENT_DATE - INTERVAL '1 day'
AND current_streak > 0;
```

## Testing the Streak System

### Manual Testing Steps:

1. **First Activity:**
   - Log a workout → Current streak = 1

2. **Next Day Activity:**
   - Log workout next day → Current streak = 2

3. **Skip a Day:**
   - Log workout after 2-day gap → Current streak = 1 (resets)

4. **View Statistics:**
   - Open profile/stats to see longest streak = 2

5. **Verify UI:**
   - _StreakCard should show current count
   - Weekly grid should show completed days with checkmarks

## Common Issues & Solutions

### Issue: Streak not updating after logging activity

**Solution:**
```dart
// Manually trigger recalculation
final streakService = StreakService();
await streakService.recalculateStreak();
```

### Issue: Activity not appearing in logs

**Verify:**
1. User is authenticated
2. Activity date is within past 7 days
3. Check Supabase `activity_log` table for records

### Issue: Widget shows loading indefinitely

**Check:**
1. Ensure user is authenticated
2. Verify Supabase connection
3. Check network connectivity
4. Review browser console for errors

## Performance Considerations

- Streak data is cached per session
- Activities are queried for last 7 days for week view
- Full recalculation happens only when needed
- Database triggers handle automatic updates

## Future Enhancements

Potential additions:
- [ ] Streak freeze/protection feature (skip one day without losing streak)
- [ ] Streak milestones and badges
- [ ] Social streak comparisons with friends
- [ ] Streak-based leaderboards
- [ ] Push notifications for streak milestones
- [ ] Streak calendars with heat maps
- [ ] Activity type tracking (different streak types)
- [ ] Streak streak statistics and analytics

## API Reference

### StreakService

**Constructor:**
```dart
StreakService()  // Singleton instance
```

**Methods:**
- `getUserStreakData()` → Future<StreakData>
- `logActivity({String activityType})` → Future<bool>
- `hasActivityToday()` → Future<bool>
- `getWeekDayStates()` → Future<List<DayState>>
- `getWeekDayLabels()` → List<String>
- `recalculateStreak()` → Future<StreakData>

## Support

For issues or questions regarding streak functionality:
1. Check this documentation
2. Review Supabase logs
3. Verify database schema is up-to-date
4. Check Flutter console for errors
