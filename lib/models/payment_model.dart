class PaymentModel {
  final String id;
  final String invoiceNumber;
  final String userId;
  final String gymId;
  final double amount;
  final String currency;
  final String status; // paid, pending, overdue, failed
  final String paymentMethod; // upi, card, netbanking, cash, auto_debit
  final String? transactionRef;
  final DateTime? paidAt;
  final DateTime? dueDate;
  final String? userName;
  final String? tierName;
  final String? avatarText;

  PaymentModel({
    required this.id,
    required this.invoiceNumber,
    required this.userId,
    required this.gymId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.transactionRef,
    this.paidAt,
    this.dueDate,
    this.userName,
    this.tierName,
    this.avatarText,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final fullName = profile?['full_name'] as String? ?? json['user_name'] as String? ?? 'Athlete';

    return PaymentModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String? ?? 'INV-000',
      userId: json['user_id'] as String,
      gymId: json['gym_id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'paid',
      paymentMethod: json['payment_method'] as String? ?? 'upi',
      transactionRef: json['transaction_ref'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'] as String) : null,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      userName: fullName,
      tierName: json['tier_name'] as String? ?? 'Elite Annual Pass',
      avatarText: fullName.isNotEmpty ? fullName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join() : 'IF',
    );
  }
}

class MembershipPlanModel {
  final String id;
  final String gymId;
  final String name;
  final String tierType;
  final double price;
  final int durationMonths;
  final List<String> features;
  final bool isPopular;
  final int activeMembers;
  final String revenueShare;

  MembershipPlanModel({
    required this.id,
    required this.gymId,
    required this.name,
    required this.tierType,
    required this.price,
    required this.durationMonths,
    required this.features,
    required this.isPopular,
    this.activeMembers = 0,
    this.revenueShare = '0%',
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    final featList = (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return MembershipPlanModel(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      name: json['name'] as String,
      tierType: json['tier_type'] as String? ?? 'pro',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (json['duration_months'] as num?)?.toInt() ?? 1,
      features: featList,
      isPopular: json['is_popular'] as bool? ?? false,
      activeMembers: (json['active_members'] as num?)?.toInt() ?? 0,
      revenueShare: json['revenue_share'] as String? ?? '0%',
    );
  }
}
