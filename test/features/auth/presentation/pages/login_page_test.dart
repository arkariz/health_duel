import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_event.dart';
import 'package:health_duel/features/auth/presentation/bloc/auth_state.dart';
import 'package:health_duel/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();

    // Default: return AuthInitial state
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    group('renders', () {
      testWidgets('all form elements correctly', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Title
        expect(find.text('Health Duel'), findsOneWidget);
        expect(find.text('Test Authentication'), findsOneWidget);

        // Form fields
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);

        // Buttons
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Sign in with Google'), findsOneWidget);
        expect(find.text("Don't have an account? Register"), findsOneWidget);

        // Test credentials hint
        expect(find.text('Test Credentials:'), findsOneWidget);
        expect(find.text('Email: test@email.com'), findsOneWidget);
        expect(find.text('Password: test123'), findsOneWidget);
      });

      testWidgets('CircularProgressIndicator when state is AuthLoading', (tester) async {
        when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
        whenListen(
          mockAuthBloc,
          const Stream<AuthState>.empty(),
          initialState: const AuthLoading(),
        );

        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
      });
    });

    group('form validation', () {
      testWidgets('shows error when email is empty', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter email'), findsOneWidget);
      });

      testWidgets('shows error when email is invalid', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Enter invalid email
        await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter valid email'), findsOneWidget);
      });

      testWidgets('shows error when password is empty', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Enter valid email but no password
        await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter password'), findsOneWidget);
      });

      testWidgets('shows error when password is too short', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Enter valid email and short password
        await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
        await tester.enterText(find.byType(TextFormField).last, '123');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });
    });

    group('sign in', () {
      testWidgets('dispatches AuthSignInWithEmailRequested when form is valid', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Enter valid credentials
        await tester.enterText(find.byType(TextFormField).first, 'test@email.com');
        await tester.enterText(find.byType(TextFormField).last, 'test123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignInWithEmailRequested(
              email: 'test@email.com',
              password: 'test123',
            ),
          ),
        ).called(1);
      });

      testWidgets('does not dispatch when form is invalid', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        verifyNever(
          () => mockAuthBloc.add(any()),
        );
      });

      testWidgets('trims email before dispatching', (tester) async {
        await tester.pumpWidget(buildSubject());

        // Enter email with trailing spaces
        await tester.enterText(find.byType(TextFormField).first, '  test@email.com  ');
        await tester.enterText(find.byType(TextFormField).last, 'test123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignInWithEmailRequested(
              email: 'test@email.com',
              password: 'test123',
            ),
          ),
        ).called(1);
      });
    });

    group('sign in with Google', () {
      testWidgets('dispatches AuthSignInWithGoogleRequested on tap', (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(find.text('Sign in with Google'));
        await tester.pump();

        verify(
          () => mockAuthBloc.add(const AuthSignInWithGoogleRequested()),
        ).called(1);
      });
    });

    group('state listeners', () {
      testWidgets('shows snackbar on AuthError', (tester) async {
        const errorMessage = 'Invalid credentials';

        whenListen(
          mockAuthBloc,
          Stream<AuthState>.fromIterable([
            const AuthError(errorMessage),
          ]),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pump(); // Rebuild after state change
        await tester.pump(); // Let snackbar appear

        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      // Note: Testing navigation to /home requires GoRouter setup
      // This is covered in integration tests
    });
  });
}
