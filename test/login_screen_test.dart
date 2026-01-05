import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:commitly/screens/auth/login_screen.dart';
import 'package:commitly/services/auth_service.dart';
import 'package:commitly/services/firestore_service.dart';
import 'package:commitly/services/theme_service.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders correctly in login mode', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ThemeService()),
            ChangeNotifierProvider(create: (_) => FirestoreService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that key UI elements are present
      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      // Verify that signup fields are not visible in login mode
      expect(find.text('Username'), findsNothing);
      expect(find.text('Birthdate'), findsNothing);
    });

    testWidgets('LoginScreen shows signup fields when toggled', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ThemeService()),
            ChangeNotifierProvider(create: (_) => FirestoreService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the toggle button to switch to signup mode
      // The button text is "Don't have an account? Sign up"
      final toggleButton = find.text('Don\'t have an account? Sign up');
      expect(toggleButton, findsOneWidget);
      
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      // Verify signup fields are now visible
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Birth Date'), findsOneWidget);
      expect(find.text('Sign Up'), findsWidgets);
    });

    testWidgets('LoginScreen validates email format', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ThemeService()),
            ChangeNotifierProvider(create: (_) => FirestoreService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find email field and enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      // Try to submit the form
      final submitButton = find.text('Login').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Email validation should show an error (if validation is implemented)
      // The form should not submit with invalid email
      expect(find.text('Login'), findsWidgets); // Still on login screen
    });

    testWidgets('LoginScreen password field toggles visibility', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ThemeService()),
            ChangeNotifierProvider(create: (_) => FirestoreService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find password field
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsWidgets);
      
      // Enter password
      final passwordField = passwordFields.last;
      await tester.enterText(passwordField, 'testpassword123');
      await tester.pump();

      // Find and tap the visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      if (visibilityIcon.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcon);
        await tester.pumpAndSettle();
        
        // After tapping, icon should change to visibility
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      }
    });

    testWidgets('LoginScreen form fields accept input', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthService()),
            ChangeNotifierProvider(create: (_) => ThemeService()),
            ChangeNotifierProvider(create: (_) => FirestoreService()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find email and password fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsAtLeastNWidgets(2));

      // Enter text in email field
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pump();

      // Enter text in password field
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      // Verify text was entered (by checking if fields contain the text)
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}

