class GymModel {
  final String id;
  final String name;
  final String slug;
  final String? tagline;
  final String address;
  final String city;
  final String state;
  final String country;
  final String timezone;
  final int maxCapacity;

  GymModel({
    required this.id,
    required this.name,
    required this.slug,
    this.tagline,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.timezone,
    required this.maxCapacity,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      tagline: json['tagline'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? 'Delhi NCR',
      state: json['state'] as String? ?? 'Delhi',
      country: json['country'] as String? ?? 'India',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      maxCapacity: (json['max_capacity'] as num?)?.toInt() ?? 110,
    );
  }
}

class GymMemberModel {
  final String id;
  final String gymId;
  final String userId;
  final String memberCode;
  final String status;
  final String? assignedTrainerId;
  final String? trainerName;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? tierName;
  final String? lastCheckIn;
  final String? expiryDate;
  final int totalCheckIns;

  GymMemberModel({
    required this.id,
    required this.gymId,
    required this.userId,
    required this.memberCode,
    required this.status,
    this.assignedTrainerId,
    this.trainerName,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.tierName,
    this.lastCheckIn,
    this.expiryDate,
    required this.totalCheckIns,
  });

  factory GymMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final trainer = json['trainer_profile'] as Map<String, dynamic>?;

    return GymMemberModel(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      userId: json['user_id'] as String,
      memberCode: json['member_code'] as String? ?? 'IF-MEMBER',
      status: json['status'] as String? ?? 'active',
      assignedTrainerId: json['assigned_trainer_id'] as String?,
      trainerName: trainer?['full_name'] as String?,
      fullName: profile?['full_name'] as String? ?? json['full_name'] as String? ?? 'Athlete',
      phone: profile?['phone'] as String? ?? json['phone'] as String?,
      avatarUrl: profile?['avatar_url'] as String? ?? json['avatar_url'] as String?,
      tierName: json['tier_name'] as String? ?? 'Elite Annual',
      lastCheckIn: json['last_check_in'] as String? ?? 'Today',
      expiryDate: json['expiry_date'] as String? ?? '2027-03-14',
      totalCheckIns: (json['total_check_ins'] as num?)?.toInt() ?? 0,
    );
  }
}
