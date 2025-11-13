class AppConstants {
  // ضع القيم الصحيحة من مشروع Supabase الخاص بك
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://larqubdkmhxcpjolhksw.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhcnF1YmRrbWh4Y3Bqb2xoa3N3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NTE1MDQsImV4cCI6MjA3NTQyNzUwNH0.Ea3PqHMAi-JwZEzbV3M0hv7qcXyjHOJnPuMnDVBe1co');

  static const String videosBucket = 'videos';
  static const int pageSize = 10;
}
