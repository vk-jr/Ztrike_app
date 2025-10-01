import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_model.dart';

class TeamRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all teams
  Future<List<TeamModel>> getTeams({String? sport}) async {
    try {
      var query = _supabase.from('teams').select();
      
      if (sport != null && sport.isNotEmpty) {
        query = query.eq('sport', sport);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get teams: $e');
    }
  }

  // Get team by ID
  Future<TeamModel?> getTeamById(String teamId) async {
    try {
      final response = await _supabase
          .from('teams')
          .select()
          .eq('id', teamId)
          .maybeSingle();

      if (response == null) return null;
      return TeamModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get team: $e');
    }
  }

  // Get leagues
  Future<List<LeagueModel>> getLeagues({String? sport}) async {
    try {
      var query = _supabase.from('leagues').select();
      
      if (sport != null && sport.isNotEmpty) {
        query = query.eq('sport', sport);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((json) => LeagueModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get leagues: $e');
    }
  }

  // Get matches
  Future<List<MatchModel>> getMatches({String? status}) async {
    try {
      var query = _supabase.from('matches').select();
      
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query.order('start_time', ascending: false);
      return (response as List).map((json) => MatchModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  // Get live matches
  Future<List<MatchModel>> getLiveMatches() async {
    return await getMatches(status: 'live');
  }

  // Get upcoming matches
  Future<List<MatchModel>> getUpcomingMatches() async {
    return await getMatches(status: 'scheduled');
  }

  // Get achievements for user
  Future<List<AchievementModel>> getAchievements(String userId) async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => AchievementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get achievements: $e');
    }
  }

  // Add achievement
  Future<AchievementModel> addAchievement({
    required String userId,
    required String title,
    String? description,
    String? year,
  }) async {
    try {
      final response = await _supabase.from('achievements').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'year': year,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return AchievementModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add achievement: $e');
    }
  }
}
