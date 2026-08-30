import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../models/personal_training_model.dart';
import '../repositories/pt_repository.dart';

final ptRepositoryProvider = Provider<PtRepository>((ref) {
  return PtRepository();
});

final coachesListProvider = FutureProvider<List<CoachModel>>((ref) async {
  final repo = ref.watch(ptRepositoryProvider);
  return repo.getCoaches(SupabaseConfig.defaultGymId);
});

final todaySessionsProvider = FutureProvider<List<PtSessionModel>>((ref) async {
  final repo = ref.watch(ptRepositoryProvider);
  return repo.getTodaySessions(SupabaseConfig.defaultGymId);
});

final ptClientsProvider = FutureProvider<List<PtClientModel>>((ref) async {
  final repo = ref.watch(ptRepositoryProvider);
  return repo.getPtClients(SupabaseConfig.defaultGymId);
});

