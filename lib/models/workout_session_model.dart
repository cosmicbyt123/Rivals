class WorkoutSessionModel {
  final String id;
  final String userId;
  final String gymId;
  final String workoutName;
  final String status; // in_progress, completed, cancelled
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final double totalVolumeKg;
  final int completedExercises;
  final int totalExercises;
  final double progressPercentage;
  final String? athleteName;
  final String? athleteAvatar;

  WorkoutSessionModel({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.workoutName,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.completedExercises,
    required this.totalExercises,
    required this.progressPercentage,
    this.athleteName,
    this.athleteAvatar,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return WorkoutSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gymId: json['gym_id'] as String,
      workoutName: json['workout_name'] as String? ?? 'Workout',
      status: json['status'] as String? ?? 'in_progress',
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (json['total_volume_kg'] as num?)?.toDouble() ?? 0.0,
      completedExercises: (json['completed_exercises'] as num?)?.toInt() ?? 0,
      totalExercises: (json['total_exercises'] as num?)?.toInt() ?? 1,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      athleteName: profile?['full_name'] as String? ?? json['athlete_name'] as String? ?? 'Athlete',
      athleteAvatar: profile?['avatar_url'] as String? ?? json['athlete_avatar'] as String?,
    );
  }
}
