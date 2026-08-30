class CoachModel {
  final String id;
  final String name;
  final String role;
  final String rating;
  final int clients;
  final int maxClients;
  final int sessionsThisMonth;
  final String revenue;
  final String specialty;
  final String avatarText;
  final String phone;
  final bool isAvailable;

  CoachModel({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.clients,
    required this.maxClients,
    required this.sessionsThisMonth,
    required this.revenue,
    required this.specialty,
    required this.avatarText,
    required this.phone,
    required this.isAvailable,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'Coach',
      rating: json['rating'] as String? ?? '4.9',
      clients: (json['clients'] as num?)?.toInt() ?? 0,
      maxClients: (json['max_clients'] as num?)?.toInt() ?? 25,
      sessionsThisMonth: (json['sessions_this_month'] as num?)?.toInt() ?? 0,
      revenue: json['revenue'] as String? ?? '₹0',
      specialty: json['specialty'] as String? ?? 'Strength Training',
      avatarText: json['avatar_text'] as String? ?? 'PT',
      phone: json['phone'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

class PtSessionModel {
  final String id;
  final String time;
  final String coachName;
  final String athleteName;
  final String focus;
  final String status; // Completed, In Progress, Upcoming
  final String avatarText;

  PtSessionModel({
    required this.id,
    required this.time,
    required this.coachName,
    required this.athleteName,
    required this.focus,
    required this.status,
    required this.avatarText,
  });

  factory PtSessionModel.fromJson(Map<String, dynamic> json) {
    return PtSessionModel(
      id: json['id'] as String,
      time: json['time'] as String,
      coachName: json['coach_name'] as String,
      athleteName: json['athlete_name'] as String,
      focus: json['focus'] as String? ?? 'Training Block',
      status: json['status'] as String? ?? 'Upcoming',
      avatarText: json['avatar_text'] as String? ?? 'AT',
    );
  }
}

class PtClientModel {
  final String id;
  final String name;
  final String coach;
  final String program;
  final String sessionsLeft;
  final double progress;
  final String renewalDue;
  final String avatarText;

  PtClientModel({
    required this.id,
    required this.name,
    required this.coach,
    required this.program,
    required this.sessionsLeft,
    required this.progress,
    required this.renewalDue,
    required this.avatarText,
  });

  factory PtClientModel.fromJson(Map<String, dynamic> json) {
    return PtClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coach: json['coach'] as String,
      program: json['program'] as String,
      sessionsLeft: json['sessions_left'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      renewalDue: json['renewal_due'] as String,
      avatarText: json['avatar_text'] as String? ?? 'PT',
    );
  }
}
