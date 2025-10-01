class TeamModel {
  final String id;
  final String name;
  final String? sport;
  final String? logo;
  final String ownerId;
  final List<String> adminIds;
  final int wins;
  final int losses;
  final int draws;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeamModel({
    required this.id,
    required this.name,
    this.sport,
    this.logo,
    required this.ownerId,
    this.adminIds = const [],
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: json['sport'] as String?,
      logo: json['logo'] as String?,
      ownerId: json['owner_id'] as String,
      adminIds: (json['admin_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sport': sport,
      'logo': logo,
      'owner_id': ownerId,
      'admin_ids': adminIds,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  int get totalMatches => wins + losses + draws;
}

class LeagueModel {
  final String id;
  final String name;
  final String? sport;
  final List<String> teams;
  final String ownerId;
  final List<String> adminIds;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeagueModel({
    required this.id,
    required this.name,
    this.sport,
    this.teams = const [],
    required this.ownerId,
    this.adminIds = const [],
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> json) {
    return LeagueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: json['sport'] as String?,
      teams: (json['teams'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ownerId: json['owner_id'] as String,
      adminIds: (json['admin_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sport': sport,
      'teams': teams,
      'owner_id': ownerId,
      'admin_ids': adminIds,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class MatchModel {
  final String id;
  final List<String> teamIds;
  final String status;
  final int scoreHome;
  final int scoreAway;
  final DateTime? startTime;
  final String? location;
  final String? leagueId;
  final String creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MatchModel({
    required this.id,
    this.teamIds = const [],
    required this.status,
    this.scoreHome = 0,
    this.scoreAway = 0,
    this.startTime,
    this.location,
    this.leagueId,
    required this.creatorId,
    this.createdAt,
    this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      teamIds: (json['team_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String,
      scoreHome: json['score_home'] as int? ?? 0,
      scoreAway: json['score_away'] as int? ?? 0,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time'] as String) : null,
      location: json['location'] as String?,
      leagueId: json['league_id'] as String?,
      creatorId: json['creator_id'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_ids': teamIds,
      'status': status,
      'score_home': scoreHome,
      'score_away': scoreAway,
      'start_time': startTime?.toIso8601String(),
      'location': location,
      'league_id': leagueId,
      'creator_id': creatorId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isLive => status == 'live';
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
}

class AchievementModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? year;
  final DateTime? createdAt;

  AchievementModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.year,
    this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      year: json['year'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'year': year,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
