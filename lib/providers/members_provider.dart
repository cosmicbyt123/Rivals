import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../models/gym_model.dart';
import '../repositories/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

final gymMembersListProvider = FutureProvider<List<GymMemberModel>>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getGymMembers(SupabaseConfig.defaultGymId);
});

final memberDashboardStatsProvider = FutureProvider<MemberDashboardData>((ref) async {
  final repo = ref.watch(memberRepositoryProvider);
  return repo.getMemberDashboard(SupabaseConfig.defaultMemberId);
});

