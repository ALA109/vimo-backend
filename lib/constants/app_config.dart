class AppConfig {
  static const String appName = 'Vimo';

  static const String supabaseUrl = 'https://larqubdkmhxcpjolhksw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhcnF1YmRrbWh4Y3Bqb2xoa3N3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NTE1MDQsImV4cCI6MjA3NTQyNzUwNH0.Ea3PqHMAi-JwZEzbV3M0hv7qcXyjHOJnPuMnDVBe1co';

  static const String videoSdkTokenEndpoint =
      'http://192.168.1.39:9090/videosdk/token'; // Update with your backend host
  static const String videoSdkViewerToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiJhYTFlYmQwMy1jYjgyLTQ3YTItOTg5ZS0wOGE5YjQ1NGJhZGIiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTc2MTMzODA4NywiZXhwIjoxNzYxOTQyODg3fQ.2xWoS9c5_8p-BphCHo2xviz-2hFO-rpa37gAYsAON9Q';
  static const String videoSdkHostToken = '';

  static const int maxVideoDuration = 60;
  static const String defaultVideoThumbnail =
      'https://your-storage-link/default_thumbnail.png';

  static const String songsBucket = 'songs';
  static const String videosBucket = 'videos';
  static const String avatarsBucket = 'avatars';

  static const int maxLiveDuration = 7200;
  static const String liveRoomPrefix = 'vimo_live_';

  // ZegoCloud credentials
  static const int zegoAppId = 569842064;
  static const String zegoAppSign =
      'be50f350092e25e18048a1cefb1a14a211a9f04c3f9b911462aead78c0d2e35c';
  static const String zegoTokenEndpoint =
      'https://vimo-backend-17f8.onrender.com/token'; // Update with your backend host

  static const int messageCharacterLimit = 500;
  static const int maxMessagesPerChat = 200;

  static const List<Map<String, dynamic>> defaultGifts = [
    {'name': 'Rose', 'icon': 'rose', 'price': 10},
    {'name': 'Heart', 'icon': 'heart', 'price': 25},
    {'name': 'Diamond', 'icon': 'diamond', 'price': 100},
    {'name': 'Rocket', 'icon': 'rocket', 'price': 250},
  ];

  static const String privacyPolicyUrl = 'https://vimo.app/privacy-policy';
  static const String termsOfServiceUrl = 'https://vimo.app/terms-of-service';

  static const bool enablePushNotifications = true;

  static const int cacheDurationHours = 12;
}
