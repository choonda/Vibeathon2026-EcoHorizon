import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  // TODO: Requires Supabase API key
  throw UnimplementedError('Supabase is not initialized. Please provide an API key.');
  // return Supabase.instance.client;
});