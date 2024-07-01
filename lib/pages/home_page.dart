import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_page.dart';
import 'club_page.dart';
import 'registered_club_page.dart';
import 'package:sign_in_button/sign_in_button.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _alreadyRegistered = false;

  late int _currentIndex;
  final List<Widget> _pages = [
    const CustomerPage(),
    const CircularProgressIndicator(), // Placeholder while checking registration
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
        if (_user != null) {
          _checkRegistrationStatus();
        }
      });
    });

    // Setze den Index basierend auf den empfangenen Argumenten
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is int) {
        setState(() {
          _currentIndex = arguments;
        });
      }
    });
  }

  Future<void> _checkRegistrationStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final QuerySnapshot userClubDocs = await FirebaseFirestore.instance
          .collection('club')
          .where('owner_id', isEqualTo: userId)
          .get();

      setState(() {
        _alreadyRegistered = userClubDocs.docs.isNotEmpty;
        if (_alreadyRegistered) {
          _pages[1] = const RegisteredClubPage();
        } else {
          _pages[1] = const ClubPage();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user != null ? _buildMainContent() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 50,
        child: SignInButton(
          Buttons.google,
          text: "Sign up with Google",
          onPressed: _handleGoogleSignIn,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Clubs finden',
          ),
          if (_alreadyRegistered)
            const BottomNavigationBarItem(
              icon: Icon(Icons.nature_people),
              label: 'Mein Club',
            )
          else
            const BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Club registrieren',
            ),
        ],
      ),
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
