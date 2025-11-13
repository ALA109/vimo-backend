import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  Supa._();

  static final SupabaseClient client = Supabase.instance.client;

  static PostgrestQueryBuilder table(String name) => client.from(name);
}
