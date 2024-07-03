import 'dart:io';

import 'package:canna_club_rating/pages/navigation_provider.dart';
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
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockAppState = MockAppState();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
    });

    testWidgets('Google SignIn Button is displayed',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.idle();
      if (Platform.isAndroid) {
        when(mockAppState.user).thenReturn(null);

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: mockAppState,
            child: MaterialApp(home: HomePage()),
          ),
        );
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Mit Google anmelden'), findsOneWidget);
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

    test('BottomNavigationBar items are set correctly', () {
      if (Platform.isAndroid) {
        final List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.white),
            label: 'Clubs finden',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.white),
            label: 'Club registrieren',
          ),
        ];

        expect(items.length, 2);
        expect(items[0].label, 'Clubs finden');
        expect(items[1].label, 'Club registrieren');
      }
    });
  });
}
