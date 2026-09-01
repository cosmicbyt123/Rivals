# Streak Functionality - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Apply Database Schema

1. Go to your Supabase dashboard
2. Open SQL Editor
3. Copy-paste all code from `supabase/profiles.sql`
4. Execute the SQL

That's it! Your database is ready.

---

### Step 2: Use Streak Service in Your Code

#### Log a Workout

```dart
import 'package:rivals/services/streak_service.dart';

// Create service instance
final streakService = StreakService();

// Log today's workout
final success = await streakService.logActivity();
if (success) {
  print('✓ Workout logged!');
}
```

#### Get Streak Data

```dart
final streakData = await streakService.getUserStreakData();

print('🔥 Current Streak: ${streakData.currentStreak} days');
print('🏆 Longest Streak: ${streakData.longestStreak} days');
print('💪 Total Workouts: ${streakData.totalWorkouts}');
```

#### Display Streak Card

The home page already has it! The `_StreakCard` widget:
- Shows current streak
- Displays weekly activity
- Allows tap-to-log
- Updates in real-time

---

### Step 3: Add Streak Stats to Profile

```dart
import 'package:rivals/widgets/streak_stats_widget.dart';

// In your profile page:
StreakStatsWidget(
  userId: currentUser.id,
)

// Or use compact version:
CompactStreakCard(
  onTap: () => Navigator.push(context, ...),
)
```

---

## 📊 Common Use Cases

### 1. Show Streak in App Bar

```dart
AppBar(
  title: CompactStreakCard(),
)
```

### 2. Button to Log Workout

```dart
ElevatedButton(
  onPressed: () async {
    final service = StreakService();
    await service.logActivity();
    // Show success message
  },
  child: Text('Complete Workout'),
)
```

### 3. Check If Already Logged Today

```dart
final hasToday = await StreakService().hasActivityToday();

if (!hasToday) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Keep Your Streak!'),
      content: Text('Log a workout to keep your streak alive'),
    ),
  );
}
```

### 4. Show Motivational Message

```dart
import 'package:rivals/utils/streak_utils.dart';

final streak = 7;
final message = StreakUtils.getMotivationalMessage(streak);
print(message); // "A week of dedication! 🏅"
```

### 5. Get Next Milestone

```dart
import 'package:rivals/utils/streak_utils.dart';

final current = 5;
final next = StreakUtils.getNextMilestone(current);
final daysLeft = StreakUtils.daysToMilestone(current);

print('Reach $next days! Only $daysLeft days left! 💪');
```

---

## 🎨 Customization

### Change Streak Card Colors

```dart
// In home_page.dart, modify the color constants:
static const gold = Color(0xFFFFC83D);        // Change this
static const surface = Color(0xFF191919);     // Or this
static const muted = Color(0xFFB9B3A8);       // Or this
```

### Customize Widget Colors

```dart
StreakStatsWidget(
  userId: userId,
  primaryColor: Color(0xFF00FF00),   // Your color
  surfaceColor: Color(0xFF111111),
  mutedColor: Color(0xFF888888),
)
```

---

## ⚙️ Configuration

### Change Activity Type

```dart
// Default is 'workout', but you can use anything:
await streakService.logActivity(
  activityType: 'meditation'
);
```

### Recalculate Streaks

Sometimes you might need to recalculate:

```dart
await streakService.recalculateStreak();
```

---

## 🧪 Testing

### Test Locally

1. **Create test user** in Supabase
2. **Log activities** for consecutive days:
   ```dart
   await streakService.logActivity();
   ```
3. **Verify** in Supabase `activity_log` table
4. **Check** streak counts in `profiles` table

### Reset for Testing

```sql
-- Clear test user's activities
DELETE FROM activity_log WHERE user_id = '<test_user_id>';

-- Reset streak counts
UPDATE profiles 
SET current_streak = 0, longest_streak = 0, total_workouts = 0
WHERE id = '<test_user_id>';
```

---

## 📱 UI Components Available

| Component | Purpose | Location |
|-----------|---------|----------|
| `_StreakCard` | Main streak display with week view | `home_page.dart` |
| `StreakStatsWidget` | Full statistics panel | `streak_stats_widget.dart` |
| `CompactStreakCard` | Mini streak badge | `streak_stats_widget.dart` |
| `StreakService` | All backend logic | `streak_service.dart` |
| `StreakUtils` | Helper calculations | `streak_utils.dart` |

---

## 🔥 Pro Tips

1. **Use Singleton**: `StreakService()` returns same instance
   ```dart
   final s1 = StreakService();
   final s2 = StreakService();
   assert(identical(s1, s2)); // true
   ```

2. **Cache Data**: Keep streakData in state to avoid repeated calls
   ```dart
   late StreakData _data;
   
   @override
   void initState() {
     _loadData();
   }
   ```

3. **Refresh on Resume**: Update streak when app comes to foreground
   ```dart
   @override
   void onRestart() {
     _loadData();
   }
   ```

4. **Handle Midnight**: Streaks update at midnight automatically
   - Database trigger handles this
   - No manual intervention needed

5. **Show Encouraging Messages**:
   ```dart
   final tier = StreakUtils.getStreakTier(streak.currentStreak);
   final emoji = tier.emoji;
   print('$emoji ${tier.description}');
   ```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Streak not updating | Check Supabase logs, verify user ID |
| Activity not appearing | Ensure user is authenticated |
| Widget showing loading | Verify internet connection |
| Streak reset unexpectedly | Check activity dates, may need recalculation |

---

## 📚 Learn More

- Full API: See [STREAK_FUNCTIONALITY.md](STREAK_FUNCTIONALITY.md)
- Database Schema: See `supabase/profiles.sql`
- Service Code: See `lib/services/streak_service.dart`
- Utils: See `lib/utils/streak_utils.dart`

---

## ✅ Checklist

Before shipping streak features:

- [ ] Database schema applied to Supabase
- [ ] `StreakService` can fetch user data
- [ ] Home page shows dynamic streak
- [ ] Tap-to-log works
- [ ] Test with multiple days of activity
- [ ] Test with missed days
- [ ] Verify longest streak updates
- [ ] Add stats to profile page
- [ ] Test UI on different screen sizes
- [ ] Verify Supabase RLS policies allow activity logging

---

## 🎯 Next Steps

1. **Try logging a workout** - Test tap-to-log on home page
2. **Add to profile** - Include stats widget in profile screen
3. **Customize colors** - Match your app theme
4. **Add notifications** - Notify users to log daily
5. **Create leaderboard** - Show streak comparisons

Happy streaking! 🔥
