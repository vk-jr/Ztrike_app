import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // App Settings Section
          _buildSectionHeader('Appearance', isDark),
          _buildThemeTile(themeProvider, isDark),
          const Divider(),

          // Language Section
          _buildSectionHeader('Language & Region', isDark),
          _buildLanguageTile(isDark),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications', isDark),
          _buildSwitchTile(
            'Enable Notifications',
            'Receive notifications from ZTRIKE',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            isDark,
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive notifications via email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
            isDark,
          ),
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
            isDark,
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader('Account', isDark),
          _buildTile(
            Icons.person_outline,
            'Account Information',
            'View and edit your profile',
            () {},
            isDark,
          ),
          _buildTile(
            Icons.lock_outline,
            'Privacy',
            'Manage your privacy settings',
            () {},
            isDark,
          ),
          _buildTile(
            Icons.security,
            'Security',
            'Password and security settings',
            () {},
            isDark,
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About', isDark),
          _buildTile(
            Icons.info_outline,
            'About ZTRIKE',
            'Version 1.0.0',
            () => _showAboutDialog(context),
            isDark,
          ),
          _buildTile(
            Icons.description_outlined,
            'Terms of Service',
            'Read our terms of service',
            () {},
            isDark,
          ),
          _buildTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Read our privacy policy',
            () {},
            isDark,
          ),
          _buildTile(
            Icons.help_outline,
            'Help & Support',
            'Get help with ZTRIKE',
            () {},
            isDark,
          ),
          const Divider(),

          // Sign Out
          _buildDangerTile(
            Icons.logout,
            'Sign Out',
            () => _showSignOutDialog(context, authProvider),
            isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(ThemeProvider themeProvider, bool isDark) {
    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        isDark ? 'Dark Mode' : 'Light Mode',
        style: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (value) => themeProvider.toggleTheme(),
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildLanguageTile(bool isDark) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
      ),
      title: Text(
        'Language',
        style: TextStyle(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        _selectedLanguage,
        style: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
      ),
      onTap: () => _showLanguageDialog(isDark),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDangerTile(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.errorColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.errorColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', isDark),
            _buildLanguageOption('Spanish', isDark),
            _buildLanguageOption('French', isDark),
            _buildLanguageOption('German', isDark),
            _buildLanguageOption('Portuguese', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isDark) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Language changed to $value')),
        );
      },
      activeColor: AppTheme.primaryColor,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ZTRIKE',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Z',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'ZTRIKE is a sports social network connecting athletes, teams, and leagues.',
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/sign-in');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
