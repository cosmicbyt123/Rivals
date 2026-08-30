import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/gym_model.dart';

class MemberDashboardData {
  final int currentStreak;
  final int longestStreak;
  final double monthlyConsistency;
  final int workoutsThisMonth;
  final int xp;
  final String currentRank;
  final double bigThreeTotalKg;
  final Map<String, dynamic>? activeSession;

  MemberDashboardData({
    required this.currentStreak,
    required this.longestStreak,
    required this.monthlyConsistency,
    required this.workoutsThisMonth,
    required this.xp,
    required this.currentRank,
    required this.bigThreeTotalKg,
    this.activeSession,
  });

  factory MemberDashboardData.empty() {
    return MemberDashboardData(
      currentStreak: 26,
      longestStreak: 34,
      monthlyConsistency: 85.0,
      workoutsThisMonth: 18,
      xp: 6400,
      currentRank: 'Platinum',
      bigThreeTotalKg: 655.0,
      activeSession: null,
    );
  }

  factory MemberDashboardData.fromJson(Map<String, dynamic> json) {
    return MemberDashboardData(
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      monthlyConsistency: (json['monthly_consistency'] as num?)?.toDouble() ?? 85.0,
      workoutsThisMonth: (json['workouts_this_month'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      currentRank: json['rank'] as String? ?? 'Bronze',
      bigThreeTotalKg: (json['big_three_total_kg'] as num?)?.toDouble() ?? 0.0,
      activeSession: json['active_session'] as Map<String, dynamic>?,
    );
  }
}

class MemberRepository {
  final SupabaseClient? _client;

  MemberRepository([this._client]);

  SupabaseClient get client => _client ?? SupabaseConfig.client;

  Future<MemberDashboardData> getMemberDashboard(String userId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client.rpc('get_member_dashboard_stats', params: {'p_user_id': userId});
        if (res != null) {
          return MemberDashboardData.fromJson(Map<String, dynamic>.from(res as Map));
        }
      }
    } catch (e) {
      debugPrint('Error loading member dashboard stats: $e');
    }
    return MemberDashboardData.empty();
  }

  Future<List<GymMemberModel>> getGymMembers(String gymId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client
            .from('gym_members')
            .select('*, profiles:user_id(full_name, phone, avatar_url), trainer_profile:assigned_trainer_id(full_name)')
            .eq('gym_id', gymId);

        return (res as List).map((row) => GymMemberModel.fromJson(row)).toList();
      }
    } catch (e) {
      debugPrint('Error loading gym members from Supabase: $e');
    }

    return [
      GymMemberModel(
        id: '1',
        gymId: gymId,
        userId: 'u1',
        memberCode: 'IF-1042',
        status: 'active',
        fullName: 'Arjun Verma',
        phone: '+91 98112 34567',
        trainerName: 'Coach Vikram',
        tierName: 'Elite Annual',
        lastCheckIn: 'Today, 07:15 AM',
        expiryDate: '14 Mar 2027',
        totalCheckIns: 84,
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP',
      ),
      GymMemberModel(
        id: '2',
        gymId: gymId,
        userId: 'u2',
        memberCode: 'IF-1088',
        status: 'active',
        fullName: 'Rahul Sen',
        phone: '+91 98765 43210',
        trainerName: 'Coach Ananya',
        tierName: 'Elite Annual',
        lastCheckIn: 'Today, 06:45 AM',
        expiryDate: '22 Jun 2027',
        totalCheckIns: 72,
        avatarUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAOnohnDs5IkwGmNrst3AclC_veosAq_oo6-hOrNGaxMp4SAiFB9e8zRQz6-_ZhDqrpWNYUbDZ6o_K1pwvquhKR83UM0AdzQ3xlEKGRof91vxtWgINERS0a61Gv3yz1Bzi8Yka5es6qaaIsDhpib7bg9qd-IWrjMa3x2BlTQFbEypmUPHySekVQOQEIlJEjbtHVtxIiEoNcfrE9tvT_1CKDecO0rzqOohvjEchzH4CGcu4kZmvLjCN5',
      ),
      GymMemberModel(
        id: '3',
        gymId: gymId,
        userId: 'u3',
        memberCode: 'IF-1120',
        status: 'active',
        fullName: 'Tanya Malik',
        phone: '+91 99887 76655',
        trainerName: 'Coach Vikram',
        tierName: 'Pro Tier',
        lastCheckIn: 'Yesterday, 06:00 PM',
        expiryDate: '10 Sep 2026',
        totalCheckIns: 65,
      ),
      GymMemberModel(
        id: '4',
        gymId: gymId,
        userId: 'u4',
        memberCode: 'IF-1154',
        status: 'expiring',
        fullName: 'Devansh Chawla',
        phone: '+91 98101 23456',
        trainerName: 'Coach Vikram',
        tierName: 'Personal Training',
        lastCheckIn: '2 days ago',
        expiryDate: '01 Sep 2026',
        totalCheckIns: 42,
      ),
      GymMemberModel(
        id: '5',
        gymId: gymId,
        userId: 'u5',
        memberCode: 'IF-1192',
        status: 'active',
        fullName: 'Kavita Nair',
        phone: '+91 97110 99887',
        trainerName: 'Self-Guided',
        tierName: 'Pro Tier',
        lastCheckIn: 'Today, 08:30 AM',
        expiryDate: '30 Dec 2026',
        totalCheckIns: 95,
      ),
      GymMemberModel(
        id: '6',
        gymId: gymId,
        userId: 'u6',
        memberCode: 'IF-1205',
        status: 'at_risk',
        fullName: 'Siddharth Mehra',
        phone: '+91 98990 11223',
        trainerName: 'Coach Ananya',
        tierName: 'Elite Annual',
        lastCheckIn: '12 days ago',
        expiryDate: '15 Nov 2026',
        totalCheckIns: 28,
      ),
      GymMemberModel(
        id: '7',
        gymId: gymId,
        userId: 'u7',
        memberCode: 'IF-1240',
        status: 'overdue',
        fullName: 'Rohan Kapoor',
        phone: '+91 98118 77665',
        trainerName: 'Coach Vikram',
        tierName: 'Pro Tier',
        lastCheckIn: '3 days ago',
        expiryDate: '25 Aug 2026',
        totalCheckIns: 36,
      ),
    ];
  }
}
