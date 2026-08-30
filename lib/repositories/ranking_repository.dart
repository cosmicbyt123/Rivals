import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/ranking_models.dart';

class RankingRepository {
  final SupabaseClient? _client;

  RankingRepository([this._client]);

  SupabaseClient get client => _client ?? SupabaseConfig.client;

  Future<List<GymRankingItem>> getGymRankings(String scope) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client
            .from('gym_rankings')
            .select('*, gyms:gym_id(name, city)')
            .order('city_rank', ascending: true);

        if ((res as List).isNotEmpty) {
          return (res).map((row) {
            final gym = row['gyms'] as Map<String, dynamic>?;
            final isOur = row['gym_id'] == SupabaseConfig.defaultGymId;
            return GymRankingItem(
              rank: (row['city_rank'] as num?)?.toInt() ?? 1,
              name: gym?['name'] as String? ?? 'Gym',
              location: gym?['city'] as String? ?? 'Delhi NCR',
              score: (row['total_score'] as num?)?.toInt().toString() ?? '0',
              change: ((row['previous_city_rank'] as num?)?.toInt() ?? 1) - ((row['city_rank'] as num?)?.toInt() ?? 1),
              members: (row['active_member_count'] as num?)?.toInt() ?? 0,
              consistency: '88%',
              isOurGym: isOur,
              avatarText: (gym?['name'] as String? ?? 'GY').split(' ').map((s) => s[0]).take(2).join(),
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading gym rankings from Supabase: $e');
    }

    return [
      GymRankingItem(
        rank: 1,
        name: 'Titan Strength Arena',
        location: 'Connaught Place, Delhi',
        score: '54,200',
        change: 0,
        members: 310,
        consistency: '92%',
        isOurGym: false,
        badge: 'DEFENDING CHAMPION',
        avatarText: 'TS',
      ),
      GymRankingItem(
        rank: 2,
        name: 'Olympus Barbell Club',
        location: 'Gurugram Sector 29',
        score: '50,370',
        change: 1,
        members: 275,
        consistency: '89%',
        isOurGym: false,
        badge: 'RISING FAST',
        avatarText: 'OB',
      ),
      GymRankingItem(
        rank: 3,
        name: 'Iron Forge Fitness',
        location: 'Hauz Khas, Delhi',
        score: '48,920',
        change: 2,
        members: 248,
        consistency: '87%',
        isOurGym: true,
        badge: 'YOUR GYM',
        avatarText: 'IF',
      ),
      GymRankingItem(
        rank: 4,
        name: 'Alpha Cult Collective',
        location: 'Noida Sector 18',
        score: '44,150',
        change: -2,
        members: 220,
        consistency: '83%',
        isOurGym: false,
        avatarText: 'AC',
      ),
      GymRankingItem(
        rank: 5,
        name: 'Vanguard Powerhouse',
        location: 'Saket, Delhi',
        score: '41,800',
        change: 1,
        members: 195,
        consistency: '81%',
        isOurGym: false,
        avatarText: 'VP',
      ),
    ];
  }

  Future<List<AthleteLeaderboardItem>> getLocalAthleteLeaderboard(String gymId) async {
    return [
      AthleteLeaderboardItem(
        rank: 1,
        name: 'Arjun Verma',
        division: 'Men\'s Open • 83kg',
        score: '2,420 pts',
        stat: '655 kg Big 3',
        highlight: '290kg Deadlift (Gym Record)',
        streak: '26d streak',
        avatarText: 'AV',
        isPrRecent: true,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP',
      ),
      AthleteLeaderboardItem(
        rank: 2,
        name: 'Rahul Sen',
        division: 'Men\'s Open • 93kg',
        score: '2,180 pts',
        stat: '620 kg Big 3',
        highlight: '240kg Squat',
        streak: '21d streak',
        avatarText: 'RS',
        isPrRecent: false,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAOnohnDs5IkwGmNrst3AclC_veosAq_oo6-hOrNGaxMp4SAiFB9e8zRQz6-_ZhDqrpWNYUbDZ6o_K1pwvquhKR83UM0AdzQ3xlEKGRof91vxtWgINERS0a61Gv3yz1Bzi8Yka5es6qaaIsDhpib7bg9qd-IWrjMa3x2BlTQFbEypmUPHySekVQOQEIlJEjbtHVtxIiEoNcfrE9tvT_1CKDecO0rzqOohvjEchzH4CGcu4kZmvLjCN5',
      ),
      AthleteLeaderboardItem(
        rank: 3,
        name: 'Tanya Malik',
        division: 'Women\'s Open • 63kg',
        score: '1,950 pts',
        stat: '395 kg Big 3',
        highlight: '185kg Deadlift (State PR)',
        streak: '29d streak',
        avatarText: 'TM',
        isPrRecent: true,
      ),
      AthleteLeaderboardItem(
        rank: 4,
        name: 'Vikram Rathore',
        division: 'Coach & Athlete • 88kg',
        score: '1,840 pts',
        stat: '590 kg Big 3',
        highlight: '160kg Bench Press',
        streak: '18d streak',
        avatarText: 'VR',
        isPrRecent: false,
      ),
      AthleteLeaderboardItem(
        rank: 5,
        name: 'Kavita Nair',
        division: 'Women\'s Open • 57kg',
        score: '1,760 pts',
        stat: '360 kg Big 3',
        highlight: '30/30 Days Consistency Queen',
        streak: '34d streak 🔥',
        avatarText: 'KN',
        isPrRecent: false,
      ),
      AthleteLeaderboardItem(
        rank: 6,
        name: 'Devansh Chawla',
        division: 'Men\'s Open • 74kg',
        score: '1,690 pts',
        stat: '540 kg Big 3',
        highlight: '210kg Squat',
        streak: '14d streak',
        avatarText: 'DC',
        isPrRecent: true,
      ),
    ];
  }
}
