import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  GoogleSignIn? _googleSignIn;
  
  // Don't initialize GoogleSignIn in constructor - it will crash without OAuth config
  // Initialize lazily only when signInWithGoogle is called

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String accountType,
    String? firstName,
    String? lastName,
    String? displayName,
  }) async {
    debugPrint('AuthService: Starting sign up for $email');
    
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null, // Disable email confirmation redirect
    );
    
    debugPrint('AuthService: Sign up response - user: ${response.user?.id}, session: ${response.session != null}');

    if (response.user == null) {
      throw Exception('Sign up failed - no user created');
    }
    
    // Check if email confirmation is required
    if (response.session == null) {
      debugPrint('AuthService: Email confirmation required');
      throw Exception('Please check your email to confirm your account before signing in');
    }
    
    // Session exists, proceed with profile creation
    debugPrint('AuthService: Session created, proceeding with profile creation');
    
    // Wait for session to be fully established
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Refresh session to ensure currentUser is set
    final refreshResult = await _supabase.auth.refreshSession();
    debugPrint('AuthService: Session refreshed - user: ${refreshResult.user?.id}');
    
    try {
      // Create user profile in database with the authenticated session
      // Determine display name:
      // 1. Use provided displayName (for teams/leagues)
      // 2. Combine firstName and lastName (for athletes)
      // 3. Fall back to email username
      String finalDisplayName;
      if (displayName != null && displayName.isNotEmpty) {
        finalDisplayName = displayName;
      } else if (firstName != null && firstName.isNotEmpty) {
        finalDisplayName = lastName != null && lastName.isNotEmpty 
            ? '$firstName $lastName' 
            : firstName;
      } else {
        finalDisplayName = email.split('@')[0];
      }
      
      debugPrint('AuthService: Creating user profile for ${response.user!.id}');
      
      await _supabase.from('users').insert({
        'auth_id': response.user!.id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'display_name': finalDisplayName,
        'display_name_lower': finalDisplayName,
        'account_type': accountType,
        'user_type': accountType,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('AuthService: User profile created successfully');
    } catch (e) {
      debugPrint('AuthService: Error creating user profile: $e');
      // If profile creation fails, throw error to inform user
      throw Exception('Failed to create user profile: $e');
    }

    return response;
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Lazy initialize Google Sign-In only when needed
      if (_googleSignIn == null) {
        try {
          _googleSignIn = GoogleSignIn();
        } catch (e) {
          throw Exception('Google Sign-In is not configured. Please set up OAuth client ID in Firebase Console.');
        }
      }
      
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google tokens');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Check if user profile exists, create if not
      if (response.user != null) {
        final existingProfile = await _supabase
            .from('users')
            .select()
            .eq('auth_id', response.user!.id)
            .maybeSingle();

        if (existingProfile == null) {
          final googleDisplayName = response.user!.userMetadata?['full_name'] ?? response.user!.email!.split('@')[0];
          final nameParts = googleDisplayName.toString().split(' ');
          final googleFirstName = nameParts.isNotEmpty ? nameParts[0] : null;
          final googleLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
          
          await _supabase.from('users').insert({
            'auth_id': response.user!.id,
            'email': response.user!.email!,
            'first_name': googleFirstName,
            'last_name': googleLastName,
            'display_name': googleDisplayName,
            'display_name_lower': googleDisplayName,
            'photo_url': response.user!.userMetadata?['avatar_url'],
            'account_type': 'athlete', // Default to athlete
            'user_type': 'player',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      return response;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _supabase.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Get current user profile from database
  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('AuthService: No authenticated user found');
      return null;
    }

    debugPrint('AuthService: Fetching profile for auth_id: ${user.id}');
    
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('AuthService: No user profile found in database for auth_id: ${user.id}');
        debugPrint('AuthService: Creating missing user profile...');
        
        // Auto-create missing profile
        // Try to extract first and last name from metadata
        final fullName = user.userMetadata?['full_name'] ?? 
                        user.userMetadata?['name'];
        String? firstName;
        String? lastName;
        String displayName;
        
        if (fullName != null) {
          final nameParts = fullName.toString().split(' ');
          firstName = nameParts.isNotEmpty ? nameParts[0] : null;
          lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
          displayName = fullName;
        } else {
          displayName = user.email?.split('@')[0] ?? 'User';
        }
        
        await _supabase.from('users').insert({
          'auth_id': user.id,
          'email': user.email!,
          'first_name': firstName,
          'last_name': lastName,
          'display_name': displayName,
          'display_name_lower': displayName,
          'photo_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          'account_type': 'athlete',
          'user_type': 'player',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        debugPrint('AuthService: User profile created successfully');
        
        // Fetch the newly created profile
        final newResponse = await _supabase
            .from('users')
            .select()
            .eq('auth_id', user.id)
            .maybeSingle();
            
        if (newResponse != null) {
          return UserModel.fromJson(newResponse);
        }
        
        // If still null after creation, return null
        return null;
      }
      
      debugPrint('AuthService: User profile found: ${response['email']}');
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('AuthService: Error fetching user profile: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
}
