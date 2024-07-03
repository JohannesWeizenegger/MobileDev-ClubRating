import 'dart:io';

import 'package:canna_club_rating/pages/navigation_provider.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:canna_club_rating/pages/customer_page.dart';
import 'package:canna_club_rating/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockAppState extends Mock implements AppState {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('HomePage Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockAppState mockAppState;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockAppState = MockAppState();
      mockUser = MockUser();
    });

    group('HomePage Widget Tests', () {
      testWidgets('Displays Google Sign-in Button if not signed in',
          (WidgetTester tester) async {
        await tester.pumpAndSettle();
        await tester.idle();

        if (Platform.isAndroid) {
          when(mockFirebaseAuth.authStateChanges())
              .thenAnswer((_) => Stream.value(null));

          expect(find.text('High Rating'), findsOneWidget);
          expect(find.byType(SignInButton), findsOneWidget);
        }
      });

      testWidgets('HomePage builds correctly', (WidgetTester tester) async {
        if (Platform.isAndroid) {
          await tester.pumpWidget(
            ChangeNotifierProvider<AppState>.value(
              value: mockAppState,
              child: MaterialApp(home: HomePage()),
            ),
          );

          expect(find.byType(HomePage), findsOneWidget);
          expect(find.byType(CustomerPage), findsOneWidget);
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        }
      });

      testWidgets('Displays CustomerPage if registered',
          (WidgetTester tester) async {
        if (Platform.isAndroid) {
          when(mockFirebaseAuth.authStateChanges())
              .thenAnswer((_) => Stream.value(mockUser));
          when(mockUser.uid).thenReturn('anotherTestUserID');

          await tester.pump();

          expect(find.byType(CustomerPage), findsOneWidget);
        }
      });
    });
  });
}
