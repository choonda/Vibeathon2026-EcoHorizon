import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ecohorizon/app.dart';
import 'package:ecohorizon/features/auth/controllers/auth_controller.dart';
import 'package:ecohorizon/features/auth/controllers/profile_controller.dart';
import 'package:ecohorizon/features/trips/controllers/trip_history_controller.dart';
import 'package:ecohorizon/features/trips/repositories/trip_repository.dart';

class MockAuthController extends AuthController {
  MockAuthController()
      : super(SupabaseClient(
          'https://plffiyhtnznqeneamwdq.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsZmZpeWh0bnpucWVuZWFtd2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NDExNjcsImV4cCI6MjA5NzAxNzE2N30.eJnxd3O_Jek5b8so7Tg3dEpc3ysvd49vJKttgKrDmF4',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ));
}

void main() {
  testWidgets('EcoHorizon app boots and shows main screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith((ref) => Stream.value(null)),
          authControllerProvider.overrideWith((ref) => MockAuthController()),
          profileRepositoryProvider.overrideWithValue(MockProfileRepository()),
          tripRepositoryProvider.overrideWithValue(MockTripRepository()),
        ],
        child: const EcoHorizonApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('EcoHorizon'), findsOneWidget);
    // Bypassed Sign in page
    // expect(find.textContaining('Sign in to load your Supabase profile'),
    //     findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
