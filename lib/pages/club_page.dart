import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'osm_service.dart';
import 'firebase_service.dart';
import 'home_page.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({Key? key}) : super(key: key);

  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubStreetController = TextEditingController();
  final TextEditingController _clubHouseNumberController =
      TextEditingController();
  final TextEditingController _clubZipCodeController = TextEditingController();
  final TextEditingController _clubCityController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerStreetController = TextEditingController();
  final TextEditingController _ownerHouseNumberController =
      TextEditingController();
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
        backgroundColor: Colors.green[900],
        title: const Text("Club Registrierung",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(
            color: Colors.white), // Setzt Icon-Farbe in der AppBar auf weiß
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors
                  .green[900], // Hintergrundfarbe des gesamten Bildschirms
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Angaben zum Club',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_clubNameController, "Name des Clubs"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                              _clubStreetController, "Straße",
                              errorText: _isClubAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: _buildTextField(
                              _clubHouseNumberController, "Hnr.",
                              errorText: _isClubAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_clubZipCodeController, "PLZ",
                              errorText: _isClubAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_clubCityController, "Ort",
                              errorText: _isClubAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Angaben zum Clubinhaber',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_ownerNameController, "Name"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                              _ownerStreetController, "Straße",
                              errorText: _isOwnerAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: _buildTextField(
                              _ownerHouseNumberController, "Hnr.",
                              errorText: _isOwnerAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_ownerZipCodeController, "PLZ",
                              errorText: _isOwnerAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(_ownerCityController, "Ort",
                              errorText: _isOwnerAddressValid
                                  ? null
                                  : 'Ungültige Adresse'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Zur vollständigen Registrierung benötigen wir ein Bild Ihres Personalausweises.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.green),
                      label: const Text('Bild mit Kamera aufnehmen',
                          style: TextStyle(color: Colors.green)),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon:
                          const Icon(Icons.photo_library, color: Colors.green),
                      label: const Text('Bild aus Galerie auswählen',
                          style: TextStyle(color: Colors.green)),
                    ),
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Image.file(_selectedImage!),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.green[800],
                          backgroundColor: Colors.white),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _validateAndSaveClubData();
                        }
                      },
                      child: const Text('Absenden',
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {String? errorText}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bitte geben Sie $labelText ein';
        }
        return null;
      },
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

    final isClubAddressValid = await OSMService.validateAddress(
        clubStreet, clubHouseNumber, clubZipCode, clubCity);
    final isOwnerAddressValid = await OSMService.validateAddress(
        ownerStreet, ownerHouseNumber, ownerZipCode, ownerCity);

    setState(() {
      _isClubAddressValid = isClubAddressValid;
      _isOwnerAddressValid = isOwnerAddressValid;
    });

    if (!isClubAddressValid || !isOwnerAddressValid) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Eine oder mehrere Adressen sind ungültig')),
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
        isLoading = false;
      });

      // Zeige die Erfolgsmeldung an
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green[900],
            title: const Text('Erfolg'),
            content: const Text(
                'Ihre Anfrage zur Registrierung wurde erfolgreich übermittelt'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Navigate to HomePage and set the index to 0 (Customer Page)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
          settings: const RouteSettings(arguments: 1),
        ),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
      });
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
