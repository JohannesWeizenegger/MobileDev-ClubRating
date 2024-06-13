import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({Key? key}) : super(key: key);

  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verkäufer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihren Namen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: "Straße",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihre Straße ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _houseNumberController,
                decoration: const InputDecoration(
                  labelText: "Hausnummer",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihre Hausnummer ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveClubData();
                  }
                },
                child: const Text('Absenden'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveClubData() async {
    final User? user = _auth.currentUser; // Get the current user
    if (user == null) {
      // If no user is signed in, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ist nicht eingeloggt')),
      );
      return;
    }

    final String userId = user.uid;
    final String name = _nameController.text;
    final String street = _streetController.text;
    final String houseNumber = _houseNumberController.text;

    try {
      await _firestore.collection('club').doc(userId).set({
        'name': name,
        'street': street,
        'house_number': houseNumber,
        'timestamp': FieldValue.serverTimestamp()
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daten erfolgreich gespeichert')),
      );

      // Optional: Felder nach dem Speichern zurücksetzen
      _nameController.clear();
      _streetController.clear();
      _houseNumberController.clear();
      print("saved");
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $error')),
      );
      print(error);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }
}
