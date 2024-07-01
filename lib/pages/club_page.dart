import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '/pages/osm_service.dart';
import '/pages/firebase_service.dart';

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
  bool isLoading = false;

  bool _isClubAddressValid = true;
  bool _isOwnerAddressValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verkäufer"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _clubStreetController,
                      decoration: InputDecoration(
                        labelText: "Straße",
                        errorText: _isClubAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "Hausnr.",
                        errorText: _isClubAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "PLZ",
                        errorText: _isClubAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "Ort",
                        errorText: _isClubAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "Straße",
                        errorText: _isOwnerAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "Hausnr.",
                        errorText: _isOwnerAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "PLZ",
                        errorText: _isOwnerAddressValid ? null : 'Ungültige Adresse',
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
                      decoration: InputDecoration(
                        labelText: "Ort",
                        errorText: _isOwnerAddressValid ? null : 'Ungültige Adresse',
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
              if (_selectedImage != null) Image.file(_selectedImage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _validateAndSaveClubData();
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

  Future<void> _validateAndSaveClubData() async {
    setState(() {
      isLoading = true;
    });

    final String clubStreet = _clubStreetController.text;
    final String clubHouseNumber = _clubHouseNumberController.text;
    final String clubZipCode = _clubZipCodeController.text;
    final String clubCity = _clubCityController.text;
    final String ownerStreet = _ownerStreetController.text;
    final String ownerHouseNumber = _ownerHouseNumberController.text;
    final String ownerZipCode = _ownerZipCodeController.text;
    final String ownerCity = _ownerCityController.text;

    final isClubAddressValid = await OSMService.validateAddress(clubStreet, clubHouseNumber, clubZipCode, clubCity);
    final isOwnerAddressValid = await OSMService.validateAddress(ownerStreet, ownerHouseNumber, ownerZipCode, ownerCity);

    setState(() {
      _isClubAddressValid = isClubAddressValid;
      _isOwnerAddressValid = isOwnerAddressValid;
      isLoading = false;
    });

    if (!isClubAddressValid || !isOwnerAddressValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eine oder mehrere Adressen sind ungültig')),
      );
      return;
    }

    try {
      await FirebaseService.saveClubData(
        clubName: _clubNameController.text,
        clubStreet: _clubStreetController.text,
        clubHouseNumber: _clubHouseNumberController.text,
        clubZipCode: _clubZipCodeController.text,
        clubCity: _clubCityController.text,
        ownerName: _ownerNameController.text,
        ownerStreet: _ownerStreetController.text,
        ownerHouseNumber: _ownerHouseNumberController.text,
        ownerZipCode: _ownerZipCodeController.text,
        ownerCity: _ownerCityController.text,
        selectedImage: _selectedImage,
      );

      setState(() {
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
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daten erfolgreich gespeichert')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $error')),
      );
    }

    setState(() {
      isLoading = false;
    });
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