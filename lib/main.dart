import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/customer_page.dart';
import 'pages/club_page.dart';
import 'pages/home_page.dart'; // Importiere die HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CannaClubRating',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(), // Ändere dies auf HomePageWithBottomNav
    );
  }
}

class HomePageWithBottomNav extends StatefulWidget {
  const HomePageWithBottomNav({Key? key}) : super(key: key);

  @override
  _HomePageWithBottomNavState createState() => _HomePageWithBottomNavState();
}

class _HomePageWithBottomNavState extends State<HomePageWithBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CustomerPage(),
    const ClubPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Clubs finden',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Club registrieren',
          ),
        ],
      ),
    );
  }
}
