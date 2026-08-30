class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String role; // member, trainer, gym_owner, admin
  final String? homeGymId;
  final int xp;
  final String currentRank;
  final double? weightKg;
  final double? heightCm;
  final String? weightClass;
  final String? bio;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.homeGymId,
    required this.xp,
    required this.currentRank,
    this.weightKg,
    this.heightCm,
    this.weightClass,
    this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Athlete',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'member',
      homeGymId: json['home_gym_id'] as String?,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      currentRank: json['current_rank'] as String? ?? 'Bronze',
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightClass: json['weight_class'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'home_gym_id': homeGymId,
      'xp': xp,
      'current_rank': currentRank,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'weight_class': weightClass,
      'bio': bio,
    };
  }
}
