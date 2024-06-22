import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ClubPage extends StatefulWidget {
  const ClubPage({Key? key}) : super(key: key);

  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubStreetController = TextEditingController();
  final TextEditingController _clubHouseNumberController = TextEditingController();
  final TextEditingController _clubZipCodeController = TextEditingController();
  final TextEditingController _clubCityController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerStreetController = TextEditingController();
  final TextEditingController _ownerHouseNumberController = TextEditingController();
  final TextEditingController _ownerZipCodeController = TextEditingController();
  final TextEditingController _ownerCityController = TextEditingController();
  File? _selectedImage;

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
              const Text(
                'Angaben zum Club',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clubNameController,
                decoration: const InputDecoration(
                  labelText: "Name des Clubs",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie den Namen des Clubs ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clubStreetController,
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
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _clubHouseNumberController,
                      decoration: const InputDecoration(
                        labelText: "Hausnr.",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihre Hausnummer ein';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clubZipCodeController,
                      decoration: const InputDecoration(
                        labelText: "PLZ",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihre Postleitzahl ein';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _clubCityController,
                      decoration: const InputDecoration(
                        labelText: "Ort",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihren Ort ein';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Angaben zum Clubinhaber',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ownerStreetController,
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
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: _ownerHouseNumberController,
                      decoration: const InputDecoration(
                        labelText: "Hausnr.",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihre Hausnummer ein';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ownerZipCodeController,
                      decoration: const InputDecoration(
                        labelText: "PLZ",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihre Postleitzahl ein';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ownerCityController,
                      decoration: const InputDecoration(
                        labelText: "Ort",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben Sie Ihren Ort ein';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Zur vollständigen Registrierung benötigen wir ein Bild Ihres Personalausweises.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Bild mit Kamera aufnehmen'),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Bild aus Galerie auswählen'),
              ),
              if (_selectedImage != null)
                Image.file(_selectedImage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveClubData();
                  }
                },
                child: const Text('Absenden'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file = await imagePicker.pickImage(source: source);
    print('${file?.path}');

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  Future<void> _saveClubData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ist nicht eingeloggt')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie ein Bild aus')),
      );
      return;
    }

    final String userId = user.uid;
    final String clubName = _clubNameController.text;
    final String clubStreet = _clubStreetController.text;
    final String clubHouseNumber = _clubHouseNumberController.text;
    final String clubZipCode = _clubZipCodeController.text;
    final String clubCity = _clubCityController.text;
    final String ownerName = _ownerNameController.text;
    final String ownerStreet = _ownerStreetController.text;
    final String ownerHouseNumber = _ownerHouseNumberController.text;
    final String ownerZipCode = _ownerZipCodeController.text;
    final String ownerCity = _ownerCityController.text;
    final String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference referenceRoot = FirebaseStorage.instance.ref();
    final Reference referenceDirImages = referenceRoot.child('images');
    final Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(_selectedImage!);
      final String imageUrl = await referenceImageToUpload.getDownloadURL();

      // Speichere die Daten in der Sammlung newClubRequests
      await FirebaseFirestore.instance.collection('newClubRequest').doc(userId).set({
        'club_name': clubName,
        'club_street': clubStreet,
        'club_house_number': clubHouseNumber,
        'club_zip_code': clubZipCode,
        'club_city': clubCity,
        'owner_name': ownerName,
        'owner_street': ownerStreet,
        'owner_house_number': ownerHouseNumber,
        'owner_zip_code': ownerZipCode,
        'owner_city': ownerCity,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Erstelle einen neuen Eintrag in der Sammlung owners und erhalte die Dokument-ID
      DocumentReference ownerRef = await FirebaseFirestore.instance.collection('owner').add({
        'name': ownerName,
        'street': ownerStreet,
        'house_number': ownerHouseNumber,
        'zip_code': ownerZipCode,
        'city': ownerCity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Speichere die Daten in der Sammlung clubs mit einer Referenz zum Owner
      await FirebaseFirestore.instance.collection('club').add({
        'name': clubName,
        'street': clubStreet,
        'house_number': clubHouseNumber,
        'zip_code': clubZipCode,
        'city': clubCity,
        'owner_id': ownerRef.id, // Referenz auf den Owner
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daten erfolgreich gespeichert')),
      );

      _clubNameController.clear();
      _clubStreetController.clear();
      _clubHouseNumberController.clear();
      _clubZipCodeController.clear();
      _clubCityController.clear();
      _ownerNameController.clear();
      _ownerStreetController.clear();
      _ownerHouseNumberController.clear();
      _ownerZipCodeController.clear();
      _ownerCityController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $error')),
      );
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubStreetController.dispose();
    _clubHouseNumberController.dispose();
    _clubZipCodeController.dispose();
    _clubCityController.dispose();
    _ownerNameController.dispose();
    _ownerStreetController.dispose();
    _ownerHouseNumberController.dispose();
    _ownerZipCodeController.dispose();
    _ownerCityController.dispose();
    super.dispose();
  }
}
