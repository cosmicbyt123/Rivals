import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../models/ranking_models.dart';
import '../repositories/ranking_repository.dart';

final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  return RankingRepository();
});

final gymRankingsProvider = FutureProvider.family<List<GymRankingItem>, String>((ref, scope) async {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.getGymRankings(scope);
});

final localAthleteLeaderboardProvider = FutureProvider<List<AthleteLeaderboardItem>>((ref) async {
  final repo = ref.watch(rankingRepositoryProvider);
  return repo.getLocalAthleteLeaderboard(SupabaseConfig.defaultGymId);
});

