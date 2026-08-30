import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../models/workout_session_model.dart';
import '../repositories/gym_repository.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository();
});

final currentGymIdProvider = StateProvider<String>((ref) {
  return SupabaseConfig.defaultGymId;
});

final gymDashboardStatsProvider = FutureProvider<GymDashboardData>((ref) async {
  final gymId = ref.watch(currentGymIdProvider);
  final repo = ref.watch(gymRepositoryProvider);
  return repo.getDashboardStats(gymId);
});

final trainingNowStreamProvider = StreamProvider.autoDispose<List<WorkoutSessionModel>>((ref) {
  final gymId = ref.watch(currentGymIdProvider);
  final repo = ref.watch(gymRepositoryProvider);
  return repo.streamTrainingNow(gymId);
});

