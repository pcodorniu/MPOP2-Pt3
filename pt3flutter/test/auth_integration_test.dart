import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pt2flutter/presentation/screens/login_view.dart';
import 'test_helpers.dart';

void main() {
  late MockAuthenticationService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthenticationService();
  });

  group('Authentication Integration Tests', () {
    testWidgets('Login Success navigates to welcome message', (tester) async {
      // Setup mock service
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);

      // Pump app (will create real repo with mock service)
      await tester.pumpApp(
        child: const LoginView(),
        authService: mockAuthService,
      );

      // Enter credentials
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      // Tap Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify UI changes (Unívoca)
      expect(find.text('Welcome, test@example.com!'), findsOneWidget);
    });

    testWidgets('Login Failure shows error message', (tester) async {
      // Setup mock error
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenThrow(Exception('Invalid credentials'));

      // Pump app
      await tester.pumpApp(
        child: const LoginView(),
        authService: mockAuthService,
      );

      // Enter credentials
      await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');

      // Tap Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify Error (Unívoca)
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('Logout returns to login form', (tester) async {
      // Setup mock for initial login
      when(
        () => mockAuthService.validateLogin(any(), any()),
      ).thenAnswer((_) async => testUser);

      // Pump app
      await tester.pumpApp(
        child: const LoginView(),
        authService: mockAuthService,
      );

      // Login first
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify we are logged in
      expect(find.text('Welcome, test@example.com!'), findsOneWidget);

      // Tap Logout
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();

      // Verify we are back at Login (Unívoca)
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
