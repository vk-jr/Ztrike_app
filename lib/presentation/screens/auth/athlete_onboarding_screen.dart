import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class AthleteOnboardingScreen extends StatefulWidget {
  const AthleteOnboardingScreen({super.key});

  @override
  State<AthleteOnboardingScreen> createState() => _AthleteOnboardingScreenState();
}

class _AthleteOnboardingScreenState extends State<AthleteOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  final _currentTeamController = TextEditingController();
  
  final List<String> _selectedSports = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _positionController.dispose();
    _currentTeamController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one sport'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.updateProfile({
      'sports': _selectedSports,
      'position': _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
      'current_team': _currentTeamController.text.trim().isEmpty ? null : _currentTeamController.text.trim(),
    });

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                const LinearProgressIndicator(
                  value: 0.5,
                  backgroundColor: AppTheme.surfaceColor,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),

                // Sports Selection
                const Text(
                  'What sports do you play?',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.sportsList.map((sport) {
                    final isSelected = _selectedSports.contains(sport);
                    return FilterChip(
                      label: Text(sport),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSports.add(sport);
                          } else {
                            _selectedSports.remove(sport);
                          }
                        });
                      },
                      selectedColor: AppTheme.primaryColor,
                      checkmarkColor: Colors.black,
                      backgroundColor: AppTheme.surfaceColor,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Position
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position (Optional)',
                    hintText: 'e.g., Forward, Midfielder',
                    prefixIcon: Icon(Icons.sports),
                  ),
                ),
                const SizedBox(height: 16),

                // Current Team
                TextFormField(
                  controller: _currentTeamController,
                  decoration: const InputDecoration(
                    labelText: 'Current Team (Optional)',
                    hintText: 'e.g., Manchester United',
                    prefixIcon: Icon(Icons.groups),
                  ),
                ),
                const SizedBox(height: 32),

                // Social Media Section
                const Text(
                  'Social Media Accounts (Optional)',
                  style: AppTheme.heading3,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect your social accounts to enhance your profile',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 16),
                
                const _SocialMediaField(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  hint: '@username',
                ),
                const SizedBox(height: 12),
                const _SocialMediaField(
                  icon: Icons.alternate_email,
                  label: 'Twitter',
                  hint: '@username',
                ),
                const SizedBox(height: 12),
                const _SocialMediaField(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  hint: 'Profile URL',
                ),
                const SizedBox(height: 48),

                // Complete Setup button
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeSetup,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Complete Setup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialMediaField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;

  const _SocialMediaField({
    required this.icon,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
