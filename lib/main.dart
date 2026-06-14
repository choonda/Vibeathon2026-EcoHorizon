import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Requires Supabase API key
  /*
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://example.supabase.co',
    ),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'demo-publishable-key',
    ),
  );
  */

  runApp(const ProviderScope(child: EcoHorizonApp()));
}
