import 'package:canna_club_rating/pages/club_page.dart';
import 'package:flutter/material.dart';
import 'customer_page.dart';
import 'club_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wählen Sie eine Rolle"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerPage()),
                );
              },
              child: const Text("Ich bin ein Kunde"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClubPage()),
                );
              },
              child: const Text("Ich bin ein Verkäufer"),
            ),
          ],
        ),
      ),
    );
  }
}
