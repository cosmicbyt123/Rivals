import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/supabase_config.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository();
});

final paymentsListProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getPayments(SupabaseConfig.defaultGymId);
});

final membershipPlansProvider = FutureProvider<List<MembershipPlanModel>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  return repo.getMembershipPlans(SupabaseConfig.defaultGymId);
});

