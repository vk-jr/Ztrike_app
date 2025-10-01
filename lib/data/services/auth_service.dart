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
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null && response.session != null) {
      // Wait a moment for session to be fully established
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        // Create user profile in database with the authenticated session
        await _supabase.from('users').insert({
          'auth_id': response.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'display_name': displayName ?? (firstName != null ? '$firstName ${lastName ?? ''}' : email.split('@')[0]),
          'display_name_lower': (displayName ?? (firstName != null ? '$firstName ${lastName ?? ''}' : email.split('@')[0])).toLowerCase(),
          'account_type': accountType,
          'user_type': accountType,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Error creating user profile: $e');
        // If profile creation fails, still return the auth response
        // The profile can be created later
      }
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
          await _supabase.from('users').insert({
            'auth_id': response.user!.id,
            'email': response.user!.email!,
            'display_name': response.user!.userMetadata?['full_name'] ?? response.user!.email!.split('@')[0],
            'display_name_lower': (response.user!.userMetadata?['full_name'] ?? response.user!.email!.split('@')[0]).toLowerCase(),
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
      print('AuthService: No authenticated user found');
      return null;
    }

    print('AuthService: Fetching profile for auth_id: ${user.id}');
    
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (response == null) {
        print('AuthService: No user profile found in database for auth_id: ${user.id}');
        print('AuthService: Creating missing user profile...');
        
        // Auto-create missing profile
        final displayName = user.userMetadata?['full_name'] ?? 
                          user.userMetadata?['name'] ?? 
                          user.email?.split('@')[0] ?? 
                          'User';
        
        await _supabase.from('users').insert({
          'auth_id': user.id,
          'email': user.email!,
          'display_name': displayName,
          'display_name_lower': displayName.toLowerCase(),
          'photo_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          'account_type': 'athlete',
          'user_type': 'player',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        print('AuthService: User profile created successfully');
        
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
      
      print('AuthService: User profile found: ${response['email']}');
      return UserModel.fromJson(response);
    } catch (e) {
      print('AuthService: Error fetching user profile: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
}
