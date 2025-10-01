import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedAccountType = AppConstants.accountTypeAthlete;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      accountType: _selectedAccountType,
      firstName: _selectedAccountType == AppConstants.accountTypeAthlete
          ? _firstNameController.text.trim()
          : null,
      lastName: _selectedAccountType == AppConstants.accountTypeAthlete
          ? _lastNameController.text.trim()
          : null,
    );

    if (success && mounted) {
      // Navigate to onboarding based on account type
      if (_selectedAccountType == AppConstants.accountTypeAthlete) {
        Navigator.of(context).pushReplacementNamed('/onboarding/athlete');
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Text(
                      'ZTRIKE',
                      style: AppTheme.heading1.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join ZTRIKE',
                      style: AppTheme.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect with the sports community',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Account Type Selector
                    Text('I am a', style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeButton(
                            label: 'Athlete',
                            isSelected: _selectedAccountType == AppConstants.accountTypeAthlete,
                            onTap: () => setState(() => _selectedAccountType = AppConstants.accountTypeAthlete),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccountTypeButton(
                            label: 'Team',
                            isSelected: _selectedAccountType == AppConstants.accountTypeTeam,
                            onTap: () => setState(() => _selectedAccountType = AppConstants.accountTypeTeam),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccountTypeButton(
                            label: 'League',
                            isSelected: _selectedAccountType == AppConstants.accountTypeLeague,
                            onTap: () => setState(() => _selectedAccountType = AppConstants.accountTypeLeague),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Name fields
                    if (_selectedAccountType == AppConstants.accountTypeAthlete) ...[
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => Validators.validateRequired(value, 'First name'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => Validators.validateRequired(value, 'Last name'),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: _selectedAccountType == AppConstants.accountTypeTeam ? 'Team Name' : 'League Name',
                          prefixIcon: const Icon(Icons.business_outlined),
                        ),
                        validator: (value) => Validators.validateRequired(value, 'Name'),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                    ),
                    const SizedBox(height: 8),

                    // Password requirements hint
                    Text(
                      'Password must contain at least 8 characters, including uppercase, lowercase, and number',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(height: 24),

                    // Sign Up button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _signUp,
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign Up'),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sign In link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/sign-in');
                          },
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
