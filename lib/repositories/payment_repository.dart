import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  final SupabaseClient? _client;

  PaymentRepository([this._client]);

  SupabaseClient get client => _client ?? SupabaseConfig.client;

  Future<List<PaymentModel>> getPayments(String gymId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client
            .from('payments')
            .select('*, profiles:user_id(full_name)')
            .eq('gym_id', gymId)
            .order('created_at', ascending: false);

        return (res as List).map((row) => PaymentModel.fromJson(row)).toList();
      }
    } catch (e) {
      debugPrint('Error loading payments from Supabase: $e');
    }

    // Default seeded payments
    return [
      PaymentModel(
        id: '1',
        invoiceNumber: 'INV-2084',
        userId: 'u1',
        gymId: gymId,
        amount: 24000,
        currency: 'INR',
        status: 'paid',
        paymentMethod: 'UPI (GooglePay)',
        paidAt: DateTime.now().subtract(const Duration(hours: 2)),
        userName: 'Arjun Verma',
        tierName: 'Elite Annual Renewal',
      ),
      PaymentModel(
        id: '2',
        invoiceNumber: 'INV-2083',
        userId: 'u2',
        gymId: gymId,
        amount: 6000,
        currency: 'INR',
        status: 'paid',
        paymentMethod: 'Auto-Debit (Card)',
        paidAt: DateTime.now().subtract(const Duration(hours: 4)),
        userName: 'Rahul Sen',
        tierName: 'Personal Training Add-on',
      ),
      PaymentModel(
        id: '3',
        invoiceNumber: 'INV-2082',
        userId: 'u3',
        gymId: gymId,
        amount: 7500,
        currency: 'INR',
        status: 'overdue',
        paymentMethod: 'Pending UPI Link',
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        userName: 'Rohan Kapoor',
        tierName: 'Pro Tier Quarterly',
      ),
      PaymentModel(
        id: '4',
        invoiceNumber: 'INV-2081',
        userId: 'u4',
        gymId: gymId,
        amount: 7500,
        currency: 'INR',
        status: 'paid',
        paymentMethod: 'UPI (Paytm)',
        paidAt: DateTime.now().subtract(const Duration(days: 2)),
        userName: 'Kavita Nair',
        tierName: 'Pro Tier Quarterly',
      ),
      PaymentModel(
        id: '5',
        invoiceNumber: 'INV-2080',
        userId: 'u5',
        gymId: gymId,
        amount: 6000,
        currency: 'INR',
        status: 'overdue',
        paymentMethod: 'Auto-Debit Failed',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        userName: 'Devansh Chawla',
        tierName: 'Personal Training 1-Mo',
      ),
      PaymentModel(
        id: '6',
        invoiceNumber: 'INV-2079',
        userId: 'u6',
        gymId: gymId,
        amount: 24000,
        currency: 'INR',
        status: 'paid',
        paymentMethod: 'NetBanking HDFC',
        paidAt: DateTime.now().subtract(const Duration(days: 6)),
        userName: 'Tanya Malik',
        tierName: 'Elite Annual Pass',
      ),
    ];
  }

  Future<List<MembershipPlanModel>> getMembershipPlans(String gymId) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await client
            .from('membership_plans')
            .select('*')
            .eq('gym_id', gymId)
            .eq('is_active', true);

        return (res as List).map((row) => MembershipPlanModel.fromJson(row)).toList();
      }
    } catch (e) {
      debugPrint('Error loading membership plans: $e');
    }

    return [
      MembershipPlanModel(
        id: 'p1',
        gymId: gymId,
        name: 'Elite Annual Pass',
        tierType: 'elite',
        price: 24000,
        durationMonths: 12,
        features: ['All Gym Access 24/7', 'Sauna & Recovery Lounge', '2 Free PT Consultations/Mo', 'Dietary Plan Included'],
        isPopular: true,
        activeMembers: 142,
        revenueShare: '51%',
      ),
      MembershipPlanModel(
        id: 'p2',
        gymId: gymId,
        name: 'Quarterly Pro Tier',
        tierType: 'pro',
        price: 7500,
        durationMonths: 3,
        features: ['Full Gym & Free Weights Access', 'Locker Facility', 'Locker & Shower Included', 'Group Classes Included'],
        isPopular: false,
        activeMembers: 68,
        revenueShare: '29%',
      ),
      MembershipPlanModel(
        id: 'p3',
        gymId: gymId,
        name: 'Standard Monthly',
        tierType: 'standard',
        price: 3000,
        durationMonths: 1,
        features: ['General Equipment Access', 'Off-Peak Priority', 'Basic Locker Access'],
        isPopular: false,
        activeMembers: 28,
        revenueShare: '14%',
      ),
      MembershipPlanModel(
        id: 'p4',
        gymId: gymId,
        name: 'Personal Coaching Add-On',
        tierType: 'pt_addon',
        price: 6000,
        durationMonths: 1,
        features: ['12 1-on-1 Sessions', 'Custom Form & PR Tracking', 'WhatsApp Support 24/7'],
        isPopular: false,
        activeMembers: 16,
        revenueShare: '6%',
      ),
    ];
  }

  Future<bool> collectPayment({
    required String gymId,
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final invoiceNum = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        await client.from('payments').insert({
          'invoice_number': invoiceNum,
          'user_id': userId,
          'gym_id': gymId,
          'amount': amount,
          'status': 'paid',
          'payment_method': paymentMethod,
          'paid_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error inserting payment in Supabase: $e');
    }
    return true;
  }
}
