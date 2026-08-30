class GymRankingItem {
  final int rank;
  final String name;
  final String location;
  final String score;
  final int change;
  final int members;
  final String consistency;
  final bool isOurGym;
  final String? badge;
  final String avatarText;

  GymRankingItem({
    required this.rank,
    required this.name,
    required this.location,
    required this.score,
    required this.change,
    required this.members,
    required this.consistency,
    required this.isOurGym,
    this.badge,
    required this.avatarText,
  });

  factory GymRankingItem.fromJson(Map<String, dynamic> json) {
    return GymRankingItem(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      name: json['name'] as String,
      location: json['location'] as String? ?? 'Delhi NCR',
      score: json['score'] as String? ?? '0',
      change: (json['change'] as num?)?.toInt() ?? 0,
      members: (json['members'] as num?)?.toInt() ?? 0,
      consistency: json['consistency'] as String? ?? '85%',
      isOurGym: json['is_our_gym'] as bool? ?? false,
      badge: json['badge'] as String?,
      avatarText: json['avatar_text'] as String? ?? 'GY',
    );
  }
}

class AthleteLeaderboardItem {
  final int rank;
  final String name;
  final String division;
  final String score;
  final String stat;
  final String highlight;
  final String streak;
  final String avatarText;
  final bool isPrRecent;
  final String? imageUrl;

  AthleteLeaderboardItem({
    required this.rank,
    required this.name,
    required this.division,
    required this.score,
    required this.stat,
    required this.highlight,
    required this.streak,
    required this.avatarText,
    required this.isPrRecent,
    this.imageUrl,
  });

  factory AthleteLeaderboardItem.fromJson(Map<String, dynamic> json) {
    return AthleteLeaderboardItem(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      name: json['name'] as String,
      division: json['division'] as String? ?? 'Men\'s Open',
      score: json['score'] as String? ?? '0 pts',
      stat: json['stat'] as String? ?? '0 kg',
      highlight: json['highlight'] as String? ?? '',
      streak: json['streak'] as String? ?? '0d streak',
      avatarText: json['avatar_text'] as String? ?? 'AT',
      isPrRecent: json['is_pr_recent'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
    );
  }
}
