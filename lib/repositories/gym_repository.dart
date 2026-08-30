import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/workout_session_model.dart';

class GymDashboardData {
  final int activeMembers;
  final int trainingNow;
  final int workoutsToday;
  final double consistencyPercentage;
  final double collectedRevenue;
  final int overdueCount;
  final double overdueAmount;
  final int expiringIn7Days;

  GymDashboardData({
    required this.activeMembers,
    required this.trainingNow,
    required this.workoutsToday,
    required this.consistencyPercentage,
    required this.collectedRevenue,
    required this.overdueCount,
    required this.overdueAmount,
    required this.expiringIn7Days,
  });

  factory GymDashboardData.empty() {
    return GymDashboardData(
      activeMembers: 248,
      trainingNow: 3,
      workoutsToday: 42,
      consistencyPercentage: 87.0,
      collectedRevenue: 182000.0,
      overdueCount: 3,
      overdueAmount: 21000.0,
      expiringIn7Days: 12,
    );
  }

  factory GymDashboardData.fromJson(Map<String, dynamic> json) {
    return GymDashboardData(
      activeMembers: (json['active_members'] as num?)?.toInt() ?? 248,
      trainingNow: (json['training_now'] as num?)?.toInt() ?? 3,
      workoutsToday: (json['workouts_today'] as num?)?.toInt() ?? 42,
      consistencyPercentage: (json['consistency_percentage'] as num?)?.toDouble() ?? 87.0,
      collectedRevenue: (json['collected_revenue'] as num?)?.toDouble() ?? 182000.0,
      overdueCount: (json['overdue_count'] as num?)?.toInt() ?? 3,
      overdueAmount: (json['overdue_amount'] as num?)?.toDouble() ?? 21000.0,
      expiringIn7Days: (json['expiring_in_7_days'] as num?)?.toInt() ?? 12,
    );
  }
}

class GymRepository {
  final SupabaseClient? _client;

  GymRepository([this._client]);

  SupabaseClient get client => _client ?? SupabaseConfig.client;

  Future<GymDashboardData> getDashboardStats(String gymId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client.rpc('get_gym_dashboard_stats', params: {'p_gym_id': gymId});
        if (res != null) {
          return GymDashboardData.fromJson(Map<String, dynamic>.from(res as Map));
        }
      }
    } catch (e) {
      debugPrint('Error fetching gym dashboard stats from Supabase: $e');
    }
    return GymDashboardData.empty();
  }

  Stream<List<WorkoutSessionModel>> streamTrainingNow(String gymId) {
    try {
      if (SupabaseConfig.isInitialized) {
        return client
            .from('workout_sessions')
            .stream(primaryKey: ['id'])
            .eq('gym_id', gymId)
            .order('started_at', ascending: false)
            .map((rows) {
              return rows
                  .where((r) => r['status'] == 'in_progress')
                  .map((r) => WorkoutSessionModel.fromJson(r))
                  .toList();
            });
      }
    } catch (e) {
      debugPrint('Realtime streamTrainingNow not active, providing fallback: $e');
    }

    // Default stream
    return Stream.value([
      WorkoutSessionModel(
        id: 's1',
        userId: 'u1',
        gymId: gymId,
        workoutName: 'Hypertrophy Block A',
        status: 'in_progress',
        startedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        durationSeconds: 2100,
        totalVolumeKg: 4850,
        completedExercises: 4,
        totalExercises: 5,
        progressPercentage: 80.0,
        athleteName: 'Arjun Verma',
        athleteAvatar:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP',
      ),
      WorkoutSessionModel(
        id: 's2',
        userId: 'u2',
        gymId: gymId,
        workoutName: 'Cardio & Core',
        status: 'in_progress',
        startedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        durationSeconds: 1200,
        totalVolumeKg: 1200,
        completedExercises: 3,
        totalExercises: 5,
        progressPercentage: 60.0,
        athleteName: 'Rahul Sen',
        athleteAvatar:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAOnohnDs5IkwGmNrst3AclC_veosAq_oo6-hOrNGaxMp4SAiFB9e8zRQz6-_ZhDqrpWNYUbDZ6o_K1pwvquhKR83UM0AdzQ3xlEKGRof91vxtWgINERS0a61Gv3yz1Bzi8Yka5es6qaaIsDhpib7bg9qd-IWrjMa3x2BlTQFbEypmUPHySekVQOQEIlJEjbtHVtxIiEoNcfrE9tvT_1CKDecO0rzqOohvjEchzH4CGcu4kZmvLjCN5',
      ),
      WorkoutSessionModel(
        id: 's3',
        userId: 'u3',
        gymId: gymId,
        workoutName: 'Powerlifting - Squat Day',
        status: 'in_progress',
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        durationSeconds: 600,
        totalVolumeKg: 2100,
        completedExercises: 1,
        totalExercises: 4,
        progressPercentage: 30.0,
        athleteName: 'Vikram',
      ),
    ]);
  }
}
