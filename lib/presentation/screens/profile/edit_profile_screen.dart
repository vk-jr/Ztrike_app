import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _positionController;

  // Image files
  XFile? _selectedBanner;
  XFile? _selectedProfileImage;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _positionController = TextEditingController(text: user?.position ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (image != null) {
      setState(() => _selectedBanner = image);
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() => _selectedProfileImage = image);
    }
  }

  Future<String?> _uploadImage(XFile file, String folder) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final path = '$folder/$fileName';

      await _supabase.storage
          .from(AppConstants.profilesBucket)
          .uploadBinary(path, bytes);

      return _supabase.storage
          .from(AppConstants.profilesBucket)
          .getPublicUrl(path);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser == null) return;

      final updates = <String, dynamic>{};

      // Handle banner upload
      if (_selectedBanner != null) {
        final bannerUrl = await _uploadImage(_selectedBanner!, 'banners');
        if (bannerUrl != null) {
          updates['banner_url'] = bannerUrl;
        }
      }

      // Handle profile image upload
      if (_selectedProfileImage != null) {
        final photoUrl = await _uploadImage(_selectedProfileImage!, 'profiles');
        if (photoUrl != null) {
          updates['photo_url'] = photoUrl;
        }
      }

      // Update text fields
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      
      if (firstName.isNotEmpty) {
        updates['first_name'] = firstName;
        updates['last_name'] = lastName;
        updates['display_name'] = lastName.isNotEmpty 
            ? '$firstName $lastName' 
            : firstName;
        updates['display_name_lower'] = updates['display_name'];
      }

      updates['bio'] = _bioController.text.trim();
      updates['position'] = _positionController.text.trim();

      // Save to database
      await authProvider.updateProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Section
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickBanner,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _selectedBanner == null && user.bannerUrl == null
                                ? const LinearGradient(
                                    colors: [AppTheme.primaryColor, AppTheme.successColor],
                                  )
                                : null,
                            image: _selectedBanner != null
                                ? null
                                : user.bannerUrl != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(user.bannerUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: _selectedBanner != null
                              ? FutureBuilder<Uint8List>(
                                  future: _selectedBanner!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                )
                              : const Center(
                                  child: Icon(Icons.camera_alt, size: 48, color: Colors.white70),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          heroTag: 'banner',
                          onPressed: _pickBanner,
                          backgroundColor: Colors.black54,
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  // Profile Picture Section
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundImage: _selectedProfileImage != null
                                      ? null
                                      : user.photoUrl != null
                                          ? CachedNetworkImageProvider(user.photoUrl!)
                                          : null,
                                  child: _selectedProfileImage != null
                                      ? FutureBuilder<Uint8List>(
                                          future: _selectedProfileImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return ClipOval(
                                                child: Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  width: 112,
                                                  height: 112,
                                                ),
                                              );
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        )
                                      : user.photoUrl == null
                                          ? const Icon(Icons.person, size: 50)
                                          : null,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: FloatingActionButton.small(
                                heroTag: 'profile',
                                onPressed: _pickProfileImage,
                                backgroundColor: AppTheme.primaryColor,
                                child: const Icon(Icons.camera_alt, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Form Fields
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // First Name
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => Validators.validateRequired(value, 'First name'),
                              ),
                              const SizedBox(height: 16),

                              // Last Name
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => Validators.validateRequired(value, 'Last name'),
                              ),
                              const SizedBox(height: 16),

                              // Bio
                              TextFormField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  prefixIcon: Icon(Icons.info_outline),
                                  hintText: 'Tell us about yourself...',
                                ),
                                maxLines: 4,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 16),

                              // Position (for athletes)
                              if (user.accountType == AppConstants.accountTypeAthlete)
                                TextFormField(
                                  controller: _positionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Position',
                                    prefixIcon: Icon(Icons.sports_soccer),
                                    hintText: 'e.g., Forward, Midfielder',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
