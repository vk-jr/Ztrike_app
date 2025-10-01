class UserModel {
  final String id;
  final String? authId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? displayNameLower;
  final String? photoUrl;
  final String? bannerUrl;
  final String? bio;
  final List<String> teams;
  final List<String> leagues;
  final List<String> connections;
  final List<String> pendingRequests;
  final List<String> sentRequests;
  final int postViews;
  final List<String> sports;
  final String? currentTeam;
  final String? accountType;
  final String? userType;
  
  // Athlete Stats
  final String? position;
  final int matchesPlayed;
  final int goals;
  final int assists;
  final int mvps;
  final int saves;
  final int wins;
  final int losses;
  final int cleanSheets;
  final double rankScore;
  
  // Team-specific
  final Map<String, dynamic>? teamInfo;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    this.authId,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.displayNameLower,
    this.photoUrl,
    this.bannerUrl,
    this.bio,
    this.teams = const [],
    this.leagues = const [],
    this.connections = const [],
    this.pendingRequests = const [],
    this.sentRequests = const [],
    this.postViews = 0,
    this.sports = const [],
    this.currentTeam,
    this.accountType,
    this.userType,
    this.position,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.mvps = 0,
    this.saves = 0,
    this.wins = 0,
    this.losses = 0,
    this.cleanSheets = 0,
    this.rankScore = 0.0,
    this.teamInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String?,
      displayNameLower: json['display_name_lower'] as String?,
      photoUrl: json['photo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      bio: json['bio'] as String?,
      teams: (json['teams'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      leagues: (json['leagues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      connections: (json['connections'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      pendingRequests: (json['pending_requests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sentRequests: (json['sent_requests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      postViews: json['post_views'] as int? ?? 0,
      sports: (json['sports'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      currentTeam: json['current_team'] as String?,
      accountType: json['account_type'] as String?,
      userType: json['user_type'] as String?,
      position: json['position'] as String?,
      matchesPlayed: json['matches_played'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      mvps: json['mvps'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      cleanSheets: json['clean_sheets'] as int? ?? 0,
      rankScore: (json['rank_score'] as num?)?.toDouble() ?? 0.0,
      teamInfo: json['team_info'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'display_name_lower': displayNameLower,
      'photo_url': photoUrl,
      'banner_url': bannerUrl,
      'bio': bio,
      'teams': teams,
      'leagues': leagues,
      'connections': connections,
      'pending_requests': pendingRequests,
      'sent_requests': sentRequests,
      'post_views': postViews,
      'sports': sports,
      'current_team': currentTeam,
      'account_type': accountType,
      'user_type': userType,
      'position': position,
      'matches_played': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'mvps': mvps,
      'saves': saves,
      'wins': wins,
      'losses': losses,
      'clean_sheets': cleanSheets,
      'rank_score': rankScore,
      'team_info': teamInfo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? authId,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? displayNameLower,
    String? photoUrl,
    String? bannerUrl,
    String? bio,
    List<String>? teams,
    List<String>? leagues,
    List<String>? connections,
    List<String>? pendingRequests,
    List<String>? sentRequests,
    int? postViews,
    List<String>? sports,
    String? currentTeam,
    String? accountType,
    String? userType,
    String? position,
    int? matchesPlayed,
    int? goals,
    int? assists,
    int? mvps,
    int? saves,
    int? wins,
    int? losses,
    int? cleanSheets,
    double? rankScore,
    Map<String, dynamic>? teamInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      displayNameLower: displayNameLower ?? this.displayNameLower,
      photoUrl: photoUrl ?? this.photoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      teams: teams ?? this.teams,
      leagues: leagues ?? this.leagues,
      connections: connections ?? this.connections,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      postViews: postViews ?? this.postViews,
      sports: sports ?? this.sports,
      currentTeam: currentTeam ?? this.currentTeam,
      accountType: accountType ?? this.accountType,
      userType: userType ?? this.userType,
      position: position ?? this.position,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      mvps: mvps ?? this.mvps,
      saves: saves ?? this.saves,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      cleanSheets: cleanSheets ?? this.cleanSheets,
      rankScore: rankScore ?? this.rankScore,
      teamInfo: teamInfo ?? this.teamInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get winRate {
    final totalMatches = wins + losses;
    if (totalMatches == 0) return 0.0;
    return (wins / totalMatches) * 100;
  }
}
