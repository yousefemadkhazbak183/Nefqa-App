import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AppUser {
  AppUser({required this.id, required this.email, required this.name});
  final String id;
  final String email;
  final String name;

  factory AppUser.fromSupabaseUser(supabase.User supabaseUser) {
    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email ?? "",
      name: supabaseUser.userMetadata?['name'] as String? ?? '',
    );
  }
}
