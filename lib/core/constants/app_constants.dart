class AppConstants {
  // App Info
  static const String appName = 'ZTRIKE';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int postsPerPage = 20;
  static const int usersPerPage = 10;
  
  // Search
  static const int searchDebounceMs = 300;
  
  // Sports List
  static const List<String> sportsList = [
    'Soccer',
    'Basketball',
    'Baseball',
    'Tennis',
    'Cricket',
    'Volleyball',
    'Hockey',
    'Rugby',
    'Others',
  ];
  
  // Account Types
  static const String accountTypeAthlete = 'athlete';
  static const String accountTypeTeam = 'team';
  static const String accountTypeLeague = 'league';
  
  // Notification Types
  static const String notificationTypeMessage = 'message';
  static const String notificationTypeConnectionRequest = 'connection_request';
  static const String notificationTypeConnectionAccepted = 'connection_accepted';
  
  // Match Status
  static const String matchStatusScheduled = 'scheduled';
  static const String matchStatusLive = 'live';
  static const String matchStatusCompleted = 'completed';
  
  // Storage Buckets
  static const String profilesBucket = 'profiles';
  static const String postsBucket = 'posts';
}
