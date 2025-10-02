import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/team_model.dart';
import '../../../data/repositories/team_repository.dart';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({super.key});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TeamRepository _teamRepository = TeamRepository();
  
  List<LeagueModel> _leagues = [];
  List<MatchModel> _liveMatches = [];
  List<MatchModel> _upcomingMatches = [];
  bool _isLoading = false;
  String? _selectedSport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final leagues = await _teamRepository.getLeagues(sport: _selectedSport);
      final liveMatches = await _teamRepository.getLiveMatches();
      final upcomingMatches = await _teamRepository.getUpcomingMatches();

      setState(() {
        _leagues = leagues;
        _liveMatches = liveMatches;
        _upcomingMatches = upcomingMatches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sport Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Sports'),
                selected: _selectedSport == null,
                onSelected: (selected) {
                  setState(() => _selectedSport = null);
                  _loadData();
                },
              ),
              const SizedBox(width: 8),
              ...AppConstants.sportsList.map((sport) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(sport),
                    selected: _selectedSport == sport,
                    onSelected: (selected) {
                      setState(() => _selectedSport = selected ? sport : null);
                      _loadData();
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live Matches'),
            Tab(text: 'Upcoming'),
            Tab(text: 'My Leagues'),
          ],
        ),

        // Tab Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Live Matches
                    _buildLiveMatchesTab(),
                    // Upcoming Matches
                    _buildUpcomingMatchesTab(),
                    // My Leagues
                    _buildMyLeaguesTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildLiveMatchesTab() {
    if (_liveMatches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No live matches right now', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _liveMatches.length,
      itemBuilder: (context, index) {
        final match = _liveMatches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      match.location ?? 'Unknown Location',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.groups, size: 32),
                          SizedBox(height: 8),
                          Text('Team 1', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${match.scoreHome} - ${match.scoreAway}',
                          style: AppTheme.heading1,
                        ),
                      ],
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.groups, size: 32),
                          SizedBox(height: 8),
                          Text('Team 2', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Watch Now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingMatchesTab() {
    if (_upcomingMatches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No upcoming matches', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingMatches.length,
      itemBuilder: (context, index) {
        final match = _upcomingMatches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Team 1 vs Team 2'),
            subtitle: Text(match.location ?? 'Unknown Location'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }

  Widget _buildMyLeaguesTab() {
    if (_leagues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No subscribed leagues', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leagues.length,
      itemBuilder: (context, index) {
        final league = _leagues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.emoji_events, color: AppTheme.warningColor),
            title: Text(league.name),
            subtitle: Text(league.sport ?? 'Unknown Sport'),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }
}
