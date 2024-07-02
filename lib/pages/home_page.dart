import 'package:canna_club_rating/pages/registered_club_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'customer_page.dart';
import 'club_page.dart';
import 'package:provider/provider.dart';
import 'navigation_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      if (event != null) {
        Provider.of<AppState>(context, listen: false).setUser(event);
        _checkRegistrationStatus(event);
      } else {
        Provider.of<AppState>(context, listen: false).clearUser();
      }
    });
  }

  Future<void> _checkRegistrationStatus(User user) async {
    final String userId = user.uid;
    final QuerySnapshot userClubDocs = await FirebaseFirestore.instance
        .collection('club')
        .where('owner_id', isEqualTo: userId)
        .get();

    final appState = Provider.of<AppState>(context, listen: false);
    appState.setAlreadyRegistered(userClubDocs.docs.isNotEmpty);
    appState.setIndex(
        0); // Gehe zu CustomerPage nach Überprüfung des Registrierungsstatus
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final List<Widget> pages = [
      const CustomerPage(),
      if (appState.alreadyRegistered)
        const RegisteredClubPage()
      else
        const ClubPage(),
    ];

    // Sicherstellen, dass currentIndex im gültigen Bereich liegt
    int currentIndex = appState.currentIndex;
    if (currentIndex < 0 || currentIndex >= pages.length) {
      currentIndex = 0;
      appState.setIndex(0);
    }

    return Scaffold(
      body: Container(
        color: Colors.green[900], // Hintergrundfarbe des gesamten Bildschirms
        child: Column(
          children: [
            Expanded(
              child: appState.user != null
                  ? _buildMainContent(appState, pages)
                  : _googleSignInButton(),
            ),
            _buildBottomNavigationBar(appState),
          ],
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _handleGoogleSignIn,
          icon: const Icon(Icons.login, color: Colors.green),
          label: const Text('Mit Google anmelden',
              style: TextStyle(color: Colors.green)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AppState appState, List<Widget> pages) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      body: pages[appState.currentIndex],
    );
  }

  Widget _buildBottomNavigationBar(AppState appState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: Colors.white, // Die weiße Trennlinie
        ),
        BottomNavigationBar(
          backgroundColor: Colors.green[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: appState.currentIndex,
          onTap: (index) {
            if (index == 1) {
              if (appState.alreadyRegistered) {
                appState.goToRegisteredClubPage();
              } else {
                appState.goToClubPage();
              }
            } else {
              appState.setIndex(index);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.white),
              label: 'Clubs finden',
            ),
            if (appState.alreadyRegistered)
              const BottomNavigationBarItem(
                icon: Icon(Icons.nature_people, color: Colors.white),
                label: 'Mein Club',
              )
            else
              const BottomNavigationBarItem(
                icon: Icon(Icons.add, color: Colors.white),
                label: 'Club registrieren',
              ),
          ],
        ),
      ],
    );
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      await _auth.signInWithProvider(googleAuthProvider);
    } catch (error) {
      print(error);
    }
  }
}
