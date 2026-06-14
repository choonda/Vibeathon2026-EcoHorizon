import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://plffiyhtnznqeneamwdq.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsZmZpeWh0bnpucWVuZWFtd2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NDExNjcsImV4cCI6MjA5NzAxNzE2N30.eJnxd3O_Jek5b8so7Tg3dEpc3ysvd49vJKttgKrDmF4',
    ),
  );

  runApp(const ProviderScope(child: EcoHorizonApp()));
}
