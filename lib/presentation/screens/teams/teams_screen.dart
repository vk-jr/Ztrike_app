import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/team_model.dart';
import '../../../data/repositories/team_repository.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TeamRepository _teamRepository = TeamRepository();
  List<TeamModel> _teams = [];
  bool _isLoading = false;
  String? _selectedSport;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    try {
      final teams = await _teamRepository.getTeams(sport: _selectedSport);
      setState(() {
        _teams = teams;
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
                  _loadTeams();
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
                      _loadTeams();
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // Teams List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _teams.isEmpty
                  ? const Center(child: Text('No teams found'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _teams.length,
                      itemBuilder: (context, index) {
                        final team = _teams[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              // TODO: Navigate to team details
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    color: AppTheme.surfaceColor,
                                    child: team.logo != null
                                        ? CachedNetworkImage(
                                            imageUrl: team.logo!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.groups, size: 48),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          team.name,
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          team.sport ?? 'Unknown Sport',
                                          style: AppTheme.caption,
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${team.wins}W - ${team.losses}L',
                                              style: AppTheme.caption,
                                            ),
                                            const Icon(Icons.arrow_forward, size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
